#import "FOXInstrumentation.h"
#import "mach_override.h"
#import <assert.h>
#import <string.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <libkern/OSAtomic.h>
#import <dispatch/dispatch.h>
#import <ffi.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#   include <MobileCoreServices/MobileCoreServices.h>
#else
#   include <CoreServices/CoreServices.h>
#endif

static struct {
    OSSpinLock lock;
    id (*objc_msgSend_reenter)(id, SEL);
    id (*objc_msgSend_injection)(id, SEL);
    bool wasOverridden;
    void (*msgReceived)(id, SEL);
} fox_objc_msgSend;

kern_return_t _FOXOverrideMsgSendWithoutLocking(void);
kern_return_t _FOXRestoreMsgSendWithoutLocking(void);

typedef void (^FreeFn)(void);
typedef struct {
    size_t size;
    ffi_type **types; // type pointers are not copied, use freers to cleanup
    FreeFn *freers;   // blocks must by copied to this array
} FOXArgTypes;

FOXArgTypes *FOXArgTypesCreate(size_t numArgs) {
    FOXArgTypes *at = (FOXArgTypes *)calloc(sizeof(FOXArgTypes), 1);
    at->size = numArgs;
    at->types = calloc(sizeof(ffi_type *), numArgs);
    at->freers = calloc(sizeof(FreeFn), numArgs);
    return at;
}

void FOXArgTypesFree(FOXArgTypes *at) {
    if (at != NULL) {
        for (unsigned int i = 0; i < at->size; i++) {
            FreeFn f = at->freers[i];
            if (f != NULL) {
                f();
                Block_release(f);
            }
        }

        free(at->types);
        free(at->freers);
    };
}

size_t _FOXArgTypeIntoFFIType(const char *type, FOXArgTypes *types, size_t index) {
#define IS_TYPE(A, B) (strncmp((A), (B), sizeof((B)) - 1) == 0)
#define SET_PTR(ptr) ({ types->types[index] = ptr; ++offsetRead; })
    size_t offsetRead = 0;
    if (strncmp(type, "r", 1) == 0) {
        ++offsetRead;
        type = type + 1;
    }
    if (IS_TYPE(type, @encode(id)) ||
        IS_TYPE(type, @encode(Class)) ||
        IS_TYPE(type, @encode(SEL)) ||
        IS_TYPE(type, @encode(void *))) {
        return SET_PTR(&ffi_type_pointer);
    } else if (strncmp(type, "^", 1) == 0 || strncmp(type, "[", 1) == 0) {
        return SET_PTR(&ffi_type_pointer);
    } else if (IS_TYPE(type, @encode(bool)) || IS_TYPE(type, @encode(BOOL))) {
        return SET_PTR(&ffi_type_schar);
    } else if (IS_TYPE(type, @encode(char))) {
        return SET_PTR(&ffi_type_schar);
    } else if (IS_TYPE(type, @encode(unsigned char))) {
        return SET_PTR(&ffi_type_uchar);
    } else if (IS_TYPE(type, @encode(short))) {
        return SET_PTR(&ffi_type_sshort);
    } else if (IS_TYPE(type, @encode(unsigned short))) {
        return SET_PTR(&ffi_type_ushort);
    } else if (IS_TYPE(type, @encode(int))) {
        return SET_PTR(&ffi_type_sint);
    } else if (IS_TYPE(type, @encode(unsigned int))) {
        return SET_PTR(&ffi_type_uint);
    } else if (IS_TYPE(type, @encode(long))) {
        return SET_PTR(&ffi_type_sint32);
    } else if (IS_TYPE(type, @encode(unsigned long))) {
        return SET_PTR(&ffi_type_uint32);
    } else if (IS_TYPE(type, @encode(long long))) {
        return SET_PTR(&ffi_type_sint64);
    } else if (IS_TYPE(type, @encode(unsigned long long))) {
        return SET_PTR(&ffi_type_uint64);
    } else if (IS_TYPE(type, @encode(float))) {
        return SET_PTR(&ffi_type_float);
    } else if (IS_TYPE(type, @encode(double))) {
        return SET_PTR(&ffi_type_double);
    } else if (IS_TYPE(type, @encode(void))) {
        return SET_PTR(&ffi_type_void);
    } else if (strncmp(type, "{", 1) == 0) {
        size_t len = strlen(type);
        size_t indexOfEq = 0;
        for (size_t i = 0; i < len; i++) {
            if (type[i] == '=') {
                indexOfEq = i;
                break;
            }
        }
         // subtract = and }, but add 1 for NULL
        size_t maxNumSubTypes = len - indexOfEq - 2 + 1;
        FOXArgTypes *subtypes = FOXArgTypesCreate(maxNumSubTypes);
        subtypes->size = 0;
        size_t structSize = 0;
        size_t read = 0;
        size_t totalRead;
        for (totalRead = indexOfEq + 1; totalRead < len; totalRead += read) {
            if (type[totalRead] == '}') {
                break;
            }
            read = _FOXArgTypeIntoFFIType(type + totalRead, subtypes, subtypes->size);
            if (!read) {
                break;
            }

            structSize += subtypes->types[subtypes->size]->size;
            ++subtypes->size;
        }

        ffi_type *struct_type = (ffi_type *)calloc(sizeof(ffi_type), 1);
        struct_type->type = FFI_TYPE_STRUCT;
        struct_type->elements = subtypes->types;
        // not required for ffi, but useful below
        struct_type->size = structSize;

        types->types[index] = struct_type;
        types->freers[index] = Block_copy(^{
            free(struct_type);
            FOXArgTypesFree(subtypes);
        });
        return totalRead;
    }
    return 0;
#undef IS_TYPE
#undef SET_PTR
}

void _FOXArgTypesIntoFFIType(Method m, FOXArgTypes *ffiTypes) {
//    printf("arg types: ");
    for (unsigned int i = 0; i < method_getNumberOfArguments(m); i++) {
        char *type = alloca(sizeof(char) * 30);
        method_getArgumentType(m, i, type, 30);
        if (_FOXArgTypeIntoFFIType(type, ffiTypes, i) == 0) {
            fprintf(stderr, "Unsupported argument type (%s) in selector (%s)\n",
                    type, sel_getName(method_getName(m)));
            assert(0);
        }
    }
//    printf("\n");
}

/// Fox's Instrumented version of objc_msgSend.
/// This overrides the existing implementation, so this method should avoid
/// calling anything that may trigger objc_msgSends by accident
FOX_EXPORT void *fox_instrumented_msgSend(id receiver, SEL selector, ...) {
    printf("objc_msgSend: %s\n", sel_getName(selector));

    OSSpinLockLock(&fox_objc_msgSend.lock);
    void (*msgReceived)(id, SEL) = fox_objc_msgSend.msgReceived;
    id (*objc_msgSend_reenter)(id, SEL) = fox_objc_msgSend.objc_msgSend_reenter;
    OSSpinLockUnlock(&fox_objc_msgSend.lock);

    if (msgReceived != NULL) {
        (*msgReceived)(receiver, selector);
    }

    if (!receiver) {
        return nil;
    }

    // whitelisted methods
    if (
        sel_isEqual(selector, @selector(resolveInstanceMethod:)) ||
        sel_isEqual(selector, @selector(resolveClassMethod:)) ||
        sel_isEqual(selector, @selector(forwardingTargetForSelector:)) ||
        sel_isEqual(selector, @selector(methodSignatureForSelector:)) ||
        sel_isEqual(selector, @selector(respondsToSelector:))
        ) {
        va_list args;
        va_start(args, selector);
        SEL s = va_arg(args, SEL);
        void *(*msg)(Class, SEL, SEL) = (typeof(msg))objc_msgSend_reenter;

        void *result = msg(receiver, selector, s);
        va_end(args);
        return result;
    }

    // allowWithZone: isn't implemented in objc objects
    if (sel_isEqual(selector, @selector(allocWithZone:))) {
        va_list args;
        va_start(args, selector);
        void *obj = va_arg(args, void *);
        void *(*msg)(Class, SEL, void *) = (typeof(msg))objc_msgSend_reenter;

        void *result = msg(receiver, selector, obj);
        va_end(args);
        return result;
    }

    const char *selectorName = sel_getName(selector);
    unsigned int numberOfArguments = 0;
    for (size_t i = 0, len = strlen(selectorName); i < len; i++) {
        if (selectorName[i] == ':') {
            numberOfArguments += 1;
        }
    }

    // 0-arg methods don't use arguments as variadic parameters
    if (numberOfArguments == 0) {
        void *(*msg)(Class, SEL) = (typeof(msg))objc_msgSend_reenter;

        void *result = msg(receiver, selector);
        return result;
    }

    // follow variadic method call

    Class receiverClass = object_getClass(receiver);
    // getInstanceMethod triggers other objc_msgSends
    Method m = class_getInstanceMethod(receiverClass, selector);

    ffi_cif call;
    char returnTypeEncoding[40];
    method_getReturnType(m, returnTypeEncoding, sizeof(returnTypeEncoding));
    FOXArgTypes *returnType = FOXArgTypesCreate(1);
    assert(_FOXArgTypeIntoFFIType(returnTypeEncoding, returnType, 0) != 0);

    unsigned int numArgs = (unsigned int)method_getNumberOfArguments(m);
    FOXArgTypes *argTypes = FOXArgTypesCreate(numArgs);
    _FOXArgTypesIntoFFIType(m, argTypes);

    ffi_status status = ffi_prep_cif_var(&call, FFI_DEFAULT_ABI, 2, numArgs, returnType->types[0], argTypes->types);

    assert(status == FFI_OK);

    id result;
//    void **passedArgs = (void **)alloca(sizeof(void *) * numArgs);
    void *passedArgs[40];
    void *buffer[50];
    size_t nextFreeByteInBuffer = 0;
    va_list args;
    va_start(args, selector);

    passedArgs[0] = (void *)&receiver;
    passedArgs[1] = (void *)&selector;
    for (size_t i = 2; i < numArgs; i++) {
        ffi_type *at = argTypes->types[i];
        printf("arg %lu -> %hu\n", i, at->type);
        if (at->type == FFI_TYPE_STRUCT) {
            NSRange r = va_arg(args, NSRange);
            printf("Range: %lu, %lu\n", r.location, r.length);
            memcpy(buffer, &r, sizeof(NSRange));
            nextFreeByteInBuffer += sizeof(NSRange);
            passedArgs[i] = buffer;
//            void *ptr = (void *)&(buffer[nextFreeByteInBuffer]);
//            for (size_t j = 0; j < at->size; j++) {
//                NSUInteger arg = va_arg(args, NSUInteger);
//                printf("struct %lu: %lu\n", j, arg);
//                buffer[nextFreeByteInBuffer++] = arg;
//            }
//            passedArgs[i] = ptr;

//        } else if (at->type == FFI_TYPE_POINTER) {
        } else {
            void *arg = va_arg(args, void *);
            printf("arg %lu: %p\n", i, arg);
            passedArgs[i] = arg;
//        } else if (at->size == sizeof(long)) {
//            long arg = va_arg(args, long);
//            passedArgs[i++] = (void *)arg;
//        } else if (at->size == sizeof(long long)) {
//            long long arg = va_arg(args, long long);
//            passedArgs[i++] = (void *)arg;
        }
    }

    ffi_call(&call, FFI_FN(objc_msgSend_reenter), &result, passedArgs);
    FOXArgTypesFree(returnType);
    FOXArgTypesFree(argTypes);
    va_end(args);
    return (id)result;
}

@interface TestClass : NSObject
@end
@implementation TestClass
+ (void)foo:(id)foo r:(NSRange)r {
    printf("TestClass: %lu, %lu\n", r.location, r.length);
}
@end

kern_return_t _FOXOverrideMsgSendWithoutLocking(void) {
    kern_return_t err = err_none;
    if (!fox_objc_msgSend.wasOverridden) {
        fox_objc_msgSend.wasOverridden = true;
        err = mach_override_ptr((void*)objc_msgSend,
                                (void*)fox_instrumented_msgSend,
                                (void**)&fox_objc_msgSend.objc_msgSend_reenter);
    }
    return err;
}

kern_return_t _FOXRestoreMsgSendWithoutLocking(void) {
    // easier than trying to restore the function
    fox_objc_msgSend.msgReceived = NULL;
    return err_none;
}

#pragma mark - Public

FOX_EXPORT void logger(id target, SEL selector) {
//    printf("%s\n", sel_getName(selector));
}

FOX_EXPORT BOOL FOXOverrideMsgSend(void (*handler)(id, SEL)) {
    OSSpinLockLock(&fox_objc_msgSend.lock);
    fox_objc_msgSend.msgReceived = handler;
    kern_return_t err = _FOXOverrideMsgSendWithoutLocking();
    OSSpinLockUnlock(&fox_objc_msgSend.lock);
    [TestClass foo:nil r:NSMakeRange(0, 1)];
    return err == err_none;
}

FOX_EXPORT BOOL FOXRestoreMsgSend(void) {
    OSSpinLockLock(&fox_objc_msgSend.lock);
    kern_return_t err = _FOXRestoreMsgSendWithoutLocking();
    OSSpinLockUnlock(&fox_objc_msgSend.lock);
    return err == err_none;
}

#import "FOXInstrumentation.h"
#import "mach_override.h"
#import <assert.h>
#import <string.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <libkern/OSAtomic.h>
#import <dispatch/dispatch.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#   include <MobileCoreServices/MobileCoreServices.h>
#else
#   include <CoreServices/CoreServices.h>
#endif

static struct {
    OSSpinLock lock;
    id (*objc_msgSend_reenter)(id, SEL);
    id (*objc_msgSend_replacement)(id, SEL);
    bool wasOverridden;
    void (*msgReceived)(NSInvocation *invocation);
} fox_objc_msgSend;

kern_return_t _FOXOverrideMsgSendWithoutLocking(void);
kern_return_t _FOXRestoreMsgSendWithoutLocking(void);

void _FOXCopyArgsIntoInvocation(NSInvocation *invocation, va_list args) {
#define IS_TYPE(A, B) (strncmp((A), (B), sizeof((B))) == 0)
#define SET_ARG(index, arg_type, type) { \
    type *v = (va_arg(args, arg_type*)); \
    [invocation setArgument:v atIndex:(index)]; \
}
#define SET_OBJ_ARG(index, arg_type, type) { \
    type v = (va_arg(args, arg_type)); \
    [invocation setArgument:&v atIndex:(index)]; \
}
    NSMethodSignature *signature = invocation.methodSignature;
    for (NSUInteger i = 2; i < signature.numberOfArguments; i++) {
        const char *type = [signature getArgumentTypeAtIndex:i];
        if (IS_TYPE(type, @encode(id)) || IS_TYPE(type, "#") || IS_TYPE(type, "^")) {
            SET_OBJ_ARG(i, id, __autoreleasing id);
        } else if (IS_TYPE(type, @encode(bool))) {
            SET_ARG(i, bool, bool);
        } else if (IS_TYPE(type, @encode(BOOL))) {
            SET_ARG(i, BOOL, BOOL);
        } else if (IS_TYPE(type, @encode(char))) {
            SET_ARG(i, char, char);
        } else if (IS_TYPE(type, @encode(unsigned char))) {
            SET_ARG(i, unsigned char, unsigned char);
        } else if (IS_TYPE(type, @encode(short))) {
            SET_ARG(i, short, short);
        } else if (IS_TYPE(type, @encode(unsigned short))) {
            SET_ARG(i, unsigned short, unsigned short);
        } else if (IS_TYPE(type, @encode(int))) {
            SET_ARG(i, int, int);
        } else if (IS_TYPE(type, @encode(unsigned int))) {
            SET_ARG(i, unsigned int, unsigned int);
        } else if (IS_TYPE(type, @encode(long))) {
            SET_ARG(i, long, long);
        } else if (IS_TYPE(type, @encode(unsigned long))) {
            SET_ARG(i, unsigned long, unsigned long);
        } else if (IS_TYPE(type, @encode(long long))) {
            SET_ARG(i, long long, long long);
        } else if (IS_TYPE(type, @encode(unsigned long long))) {
            SET_ARG(i, unsigned long long, unsigned long long);
        } else if (IS_TYPE(type, @encode(float))) {
            SET_ARG(i, float, float);
        } else if (IS_TYPE(type, @encode(double))) {
            SET_ARG(i, double, double);
        } else {
            [NSException raise:NSInvalidArgumentException format:@"Unsupported argument in selector (%@): '%s'", NSStringFromSelector(invocation.selector), type];
        }    }
#undef SET_ARG
#undef EQ_TYPE
}

static id objc_msgSend_replacement(id receiver, SEL selector, ...) {
    OSSpinLockLock(&fox_objc_msgSend.lock);
    if (fox_objc_msgSend.msgReceived != NULL) {
        _FOXRestoreMsgSendWithoutLocking();
        NSMethodSignature *signature = [receiver methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = receiver;
        invocation.selector = selector;
        va_list args;
        va_start(args, selector);
        _FOXCopyArgsIntoInvocation(invocation, args);
        va_end(args);
        (*fox_objc_msgSend.msgReceived)(invocation);
        _FOXOverrideMsgSendWithoutLocking();
    }
    id result = fox_objc_msgSend.objc_msgSend_reenter(receiver, selector);
    OSSpinLockUnlock(&fox_objc_msgSend.lock);
    return result;
}

kern_return_t _FOXOverrideMsgSendWithoutLocking(void) {
    kern_return_t err = err_none;
    if (!fox_objc_msgSend.wasOverridden) {
        fox_objc_msgSend.wasOverridden = true;
        err = mach_override_ptr((void*)objc_msgSend,
                                (void*)fox_objc_msgSend.objc_msgSend_replacement,
                                (void**)&objc_msgSend_replacement);
    }
    return err;
}

kern_return_t _FOXRestoreMsgSendWithoutLocking(void) {
    // easier than trying to restore the function
    fox_objc_msgSend.msgReceived = NULL;
    return err_none;
}

#pragma mark - Public

FOX_EXTERN kern_return_t FOXOverrideMsgSend(void (*handler)(NSInvocation *invocation)) {
    OSSpinLockLock(&fox_objc_msgSend.lock);
    fox_objc_msgSend.msgReceived = handler;
    kern_return_t err = _FOXOverrideMsgSendWithoutLocking();
    OSSpinLockUnlock(&fox_objc_msgSend.lock);
    return err;
}

FOX_EXTERN kern_return_t FOXRestoreMsgSend(void) {
    OSSpinLockLock(&fox_objc_msgSend.lock);
    kern_return_t err = _FOXRestoreMsgSendWithoutLocking();
    OSSpinLockUnlock(&fox_objc_msgSend.lock);
    return err;
}

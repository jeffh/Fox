#import "FOXTransition.h"
#import "FOXGenerator.h"
#import "FOXCoreGenerators.h"


static void FOXPrepareInvocation(NSInvocation *invocation, NSArray *values);
static id FOXBoxReturnFromInvocation(NSInvocation *invocation);


@implementation FOXTransition

+ (instancetype)byCallingSelector:(SEL)selector
                    withGenerator:(id<FOXGenerator>)generator
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState
{
    FOXTransition *transition = [[FOXTransition alloc] initWithAction:^id(id subject, id generatedValue) {
        NSMethodSignature *signature = [subject methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];

        NSArray *arguments = [NSArray arrayWithObject:generatedValue];
        if ([generatedValue isKindOfClass:[NSArray class]]) {
            arguments = generatedValue;
        }
        FOXPrepareInvocation(invocation, arguments);

        invocation.selector = selector;
        [invocation invokeWithTarget:subject];

        return FOXBoxReturnFromInvocation(invocation);
    } nextModelState:nextState];
    transition.name = NSStringFromSelector(selector);
    transition.generator = generator;
    return transition;
}

+ (instancetype)byCallingSelector:(SEL)selector
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState
{
    return [self byCallingSelector:selector withGenerator:nil nextModelState:nextState];
}

- (instancetype)initWithGenerator:(id<FOXGenerator>)generator
                           action:(id(^)(id subject, id generatedValue))action
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState
{
    self = [super init];
    if (self) {
        self.generator = generator;
        self.action = action;
        self.nextState = nextState;
    }
    return self;
}

- (instancetype)initWithAction:(id(^)(id subject, id generatedValue))action
                nextModelState:(id (^)(id modelState, id generatedValue))nextState
{
    return [self initWithGenerator:nil action:action nextModelState:nextState];
}

#pragma mark - FOXStateTransition

- (NSString *)descriptionWithGeneratedValue:(id)generatedValue {
    if ([self.name rangeOfString:@":"].location == NSNotFound) {
        return self.name;
    }
    return [NSString stringWithFormat:@"%@%@", self.name, generatedValue];
}

- (BOOL)satisfiesPreConditionForModelState:(id)modelState
{
    if (self.precondition) {
        return self.precondition(modelState);
    } else {
        return YES;
    }
}

- (id<FOXGenerator>)generator
{
    if (!_generator) {
        _generator = FOXReturn(@[]);
    }
    return _generator;
}

- (id)nextModelStateFromModelState:(id)previousModelState generatedValue:(id)generatedValue
{
    return self.nextState(previousModelState, generatedValue);
}

- (id)objectReturnedByInvokingSubject:(id)subject generatedValue:(id)generatedValue
{
    return self.action(subject, generatedValue);
}

- (BOOL)satisfiesPostConditionInModelState:(id)currentModelState
                            fromModelState:(id)previousModelState
                                   subject:(id)subject
                            generatedValue:(id)generatedValue
                   objectReturnedBySubject:(id)objectReturned
{
    if (self.postcondition) {
        return self.postcondition(currentModelState, previousModelState, subject, generatedValue, objectReturned);
    } else {
        return YES;
    }
}

@end


#define IS_TYPE(A, B) (strncmp(A, B, sizeof(B)) == 0)

static void FOXPrepareInvocation(NSInvocation *invocation, NSArray *values)
{
    NSMethodSignature *signature = invocation.methodSignature;
    NSCAssert(values.count == signature.numberOfArguments - 2, @"Not enough args");
#define SET_ARG(value, type) {type v = (value); [invocation setArgument:&v atIndex:i];}
    for (NSUInteger i = 2; i<[signature numberOfArguments]; i++) {
        id value = values[i - 2];
        const char *type = [signature getArgumentTypeAtIndex:i];
        if (IS_TYPE(type, @encode(id)) || IS_TYPE(type, "#") || IS_TYPE(type, "^")) {
            SET_ARG(value, __autoreleasing id);
        } else if (IS_TYPE(type, @encode(bool))) {
            SET_ARG([value boolValue], bool);
        } else if (IS_TYPE(type, @encode(BOOL))) {
            SET_ARG([value boolValue], BOOL);
        } else if (IS_TYPE(type, @encode(char))) {
            SET_ARG([value charValue], char);
        } else if (IS_TYPE(type, @encode(unsigned char))) {
            SET_ARG([value unsignedCharValue], unsigned char);
        } else if (IS_TYPE(type, @encode(short))) {
            SET_ARG([value shortValue], short);
        } else if (IS_TYPE(type, @encode(unsigned short))) {
            SET_ARG([value unsignedShortValue], unsigned short);
        } else if (IS_TYPE(type, @encode(int))) {
            SET_ARG([value intValue], int);
        } else if (IS_TYPE(type, @encode(unsigned int))) {
            SET_ARG([value unsignedIntValue], unsigned int);
        } else if (IS_TYPE(type, @encode(long))) {
            SET_ARG([value longValue], long);
        } else if (IS_TYPE(type, @encode(unsigned long))) {
            SET_ARG([value unsignedLongValue], unsigned long);
        } else if (IS_TYPE(type, @encode(long long))) {
            SET_ARG([value longLongValue], long long);
        } else if (IS_TYPE(type, @encode(unsigned long long))) {
            SET_ARG([value unsignedLongLongValue], unsigned long long);
        } else if (IS_TYPE(type, @encode(float))) {
            SET_ARG([value floatValue], float);
        } else if (IS_TYPE(type, @encode(double))) {
            SET_ARG([value doubleValue], double);
        } else {
            [NSException raise:NSInvalidArgumentException format:@"Unsupported argument in selector (%@): '%s'", NSStringFromSelector(invocation.selector), type];
        }
    }
#undef SET_ARG
}

static id FOXBoxReturnFromInvocation(NSInvocation *invocation)
{
    NSMethodSignature *signature = invocation.methodSignature;

    __autoreleasing id returnedObject = nil;

    if (signature.methodReturnLength > 0) {
        const char *returnType = signature.methodReturnType;
        if (IS_TYPE(returnType, @encode(id)) || IS_TYPE(returnType, "#") || IS_TYPE(returnType, "^")) {
            [invocation getReturnValue:&returnedObject];
        } else {
            void *buffer = (void *)alloca(signature.methodReturnLength);
            [invocation getReturnValue:&buffer];
            returnedObject = [NSValue value:buffer withObjCType:returnType];
        }
    }
    return returnedObject;
}

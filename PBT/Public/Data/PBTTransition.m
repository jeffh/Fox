#import "PBTTransition.h"
#import "PBTGenerator.h"
#include "PBTCoreGenerators.h"


@implementation PBTTransition

+ (instancetype)byCallingSelector:(SEL)selector
                    withGenerator:(id<PBTGenerator>)generator
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState
{
    PBTTransition *transition = [[PBTTransition alloc] initWithAction:^id(id actualState, id generatedValue) {
        NSMethodSignature *signature = [actualState methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        __autoreleasing id obj = generatedValue;
        if (signature.numberOfArguments > 2 && strcmp([signature getArgumentTypeAtIndex:2], @encode(id)) == 0) {
            [invocation setArgument:&obj atIndex:2];
        }

        invocation.selector = selector;
        [invocation invokeWithTarget:actualState];

        if (signature.methodReturnLength > 0 || strcmp(signature.methodReturnType, @encode(id)) == 0) {
            __autoreleasing id returnedObj = nil;
            [invocation getReturnValue:&returnedObj];
            return returnedObj;
        }
        return nil;
    } nextModelState:nextState];
    transition.name = NSStringFromSelector(selector);
    transition.generator = generator;
    return transition;
}

+ (instancetype)forCallingSelector:(SEL)selector
                    nextModelState:(id (^)(id modelState, id generatedValue))nextState
{
    return [self byCallingSelector:selector withGenerator:nil nextModelState:nextState];
}

- (instancetype)initWithGenerator:(id<PBTGenerator>)generator
                           action:(id(^)(id actualState, id generatedValue))action
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


- (instancetype)initWithAction:(id(^)(id actualState, id generatedValue))action
                nextModelState:(id (^)(id modelState, id generatedValue))nextState
{
    return [self initWithGenerator:nil action:action nextModelState:nextState];
}

- (NSString *)description
{
    return self.name;
}

#pragma mark - PBTStateTransition

- (BOOL)satisfiesPreConditionForModelState:(id)modelState
{
    if (self.precondition) {
        return self.precondition(modelState);
    } else {
        return YES;
    }
}

- (id<PBTGenerator>)generator
{
    if (!_generator) {
        _generator = PBTReturn(@[]);
    }
    return _generator;
}

- (id)nextModelStateFromModelState:(id)previousModelState generatedValue:(id)generatedValue
{
    return self.nextState(previousModelState, generatedValue);
}

- (id)objectFromAdvancingActualState:(id)actualState generatedValue:(id)generatedValue
{
    return self.action(actualState, generatedValue);
}

- (BOOL)satisfiesPostConditionInModelState:(id)currentModelState
                            fromModelState:(id)previousModelState
                               actualState:(id)actualState
                            generatedValue:(id)generatedValue
               returnedObjectFromAdvancing:(id)actualStateResult
{
    if (self.postcondition) {
        return self.postcondition(currentModelState, previousModelState, actualState, generatedValue, actualStateResult);
    } else {
        return YES;
    }
}

@end

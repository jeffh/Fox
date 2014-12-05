#import "FOXFiniteStateMachine.h"
#import "FOXStateTransition.h"
#import "FOXCommand.h"
#import "FOXExecutedCommand.h"
#import "FOXArray.h"


@interface FOXFiniteStateMachine ()
@property (nonatomic) id initialModelState;
@property (nonatomic) NSMutableArray *transitions;
@end


@implementation FOXFiniteStateMachine

- (instancetype)initWithInitialModelState:(id)initialModelState
{
    self = [super init];
    if (self) {
        self.initialModelState = initialModelState;
        self.transitions = [NSMutableArray array];
    }
    return self;
}

- (void)addTransition:(id<FOXStateTransition>)transition
{
    NSParameterAssert([transition conformsToProtocol:@protocol(FOXStateTransition)]);
    [self.transitions addObject:transition];
}

- (NSArray *)allTransitions
{
    return self.transitions;
}

- (BOOL)isValidCommandSequence:(NSArray *)commands
{
    id modelState = self.initialModelState;
    for (FOXCommand *command in commands) {
        id<FOXStateTransition> transition = command.transition;
        id generatedValue = command.generatedValue;
        if (![transition satisfiesPreConditionForModelState:modelState]) {
            return NO;
        }
        modelState = [transition nextModelStateFromModelState:modelState generatedValue:generatedValue];
    }
    return YES;
}

- (NSArray *)executeCommandSequence:(NSArray *)commands subject:(id)subject
{
    NSMutableArray *executedCommands = [NSMutableArray array];
    id modelState = self.initialModelState;
    for (FOXCommand *command in commands) {
        id<FOXStateTransition> transition = command.transition;
        id generatedValue = command.generatedValue;
        id previousModalState = modelState;

        FOXExecutedCommand *executedCommand = [[FOXExecutedCommand alloc] init];
        executedCommand.command = command;
        executedCommand.dateExecuted = [NSDate date];
        executedCommand.modelStateBeforeExecution = modelState;
        [executedCommands addObject:executedCommand];

        if ([transition respondsToSelector:@selector(satisfiesPreConditionForModelState:)]) {
            if (![transition satisfiesPreConditionForModelState:modelState]) {
                break;
            }
        }
        modelState = [transition nextModelStateFromModelState:modelState generatedValue:generatedValue];

        id resultingValue = nil;

        @try {
            resultingValue = [transition objectReturnedByInvokingSubject:subject generatedValue:generatedValue];
        }
        @catch (NSException *exception) {
            executedCommand.raisedException = exception;
        }

        executedCommand.satisfiesPrecondition = YES;
        executedCommand.objectReturnedBySubject = resultingValue;
        executedCommand.modelStateAfterExecution = modelState;

        if (executedCommand.raisedException) {
            break;
        }

        if ([transition respondsToSelector:@selector(satisfiesPostConditionInModelState:fromModelState:subject:generatedValue:objectReturnedBySubject:)]) {
            if (![transition satisfiesPostConditionInModelState:modelState
                                                 fromModelState:previousModalState
                                                        subject:subject
                                                 generatedValue:generatedValue
                                        objectReturnedBySubject:resultingValue]) {
                break;
            }
        }

        executedCommand.satisfiesPostcondition = YES;
    }
    FOXArray *prettyExecutedCommands = [[FOXArray alloc] initWithArray:executedCommands];
    return prettyExecutedCommands;
}

@end

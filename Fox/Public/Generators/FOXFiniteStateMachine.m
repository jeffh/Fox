#import "FOXFiniteStateMachine.h"
#import "FOXStateTransition.h"
#import "FOXCommand.h"
#import "FOXExecutedCommand.h"
#import "FOXPrettyArray.h"


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

#pragma mark - FOXStateMachine

- (void)addTransition:(id<FOXStateTransition>)transition
{
    NSParameterAssert([transition conformsToProtocol:@protocol(FOXStateTransition)]);
    [self.transitions addObject:transition];
}

- (NSArray *)allTransitions
{
    return self.transitions;
}

- (id)modelStateFromCommandSequence:(NSArray *)commands
{
    return [self modelStateFromCommandSequence:commands startingModelState:self.initialModelState];
}

- (id)modelStateFromCommandSequence:(NSArray *)commands startingModelState:(id)modelState
{
    for (FOXCommand *command in commands) {
        id<FOXStateTransition> transition = command.transition;
        id generatedValue = command.generatedValue;
        if (![transition satisfiesPreConditionForModelState:modelState]) {
            return nil;
        }
        modelState = [transition nextModelStateFromModelState:modelState generatedValue:generatedValue];
    }
    return modelState;
}

- (NSArray *)executeCommandSequence:(NSArray *)commands subject:(id)subject
{
    return [self executeCommandSequence:commands subject:subject startingModelState:self.initialModelState];
}

- (NSArray *)executeCommandSequence:(NSArray *)commands subject:(id)subject startingModelState:(id)modelState
{
    NSMutableArray *executedCommands = [NSMutableArray array];
    for (FOXCommand *command in commands) {
        id<FOXStateTransition> transition = command.transition;
        id generatedValue = command.generatedValue;
        id previousModalState = modelState;

        FOXExecutedCommand *executedCommand = [[FOXExecutedCommand alloc] init];
        executedCommand.timeExecuted = CFAbsoluteTimeGetCurrent();
        executedCommand.command = command;
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
    return [FOXPrettyArray arrayWithArray:executedCommands];
}

@end

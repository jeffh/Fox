#import "PBTFiniteStateMachine.h"
#import "PBTStateTransition.h"
#import "PBTCommand.h"


@interface PBTFiniteStateMachine ()
@property (nonatomic) id initialModelState;
@property (nonatomic) NSMutableArray *transitions;
@end


@implementation PBTFiniteStateMachine

- (instancetype)initWithInitialModelState:(id)initialModelState
{
    self = [super init];
    if (self) {
        self.initialModelState = initialModelState;
        self.transitions = [NSMutableArray array];
    }
    return self;
}

- (void)addTransition:(id<PBTStateTransition>)transition
{
    NSParameterAssert([transition conformsToProtocol:@protocol(PBTStateTransition)]);
    [self.transitions addObject:transition];
}

- (NSArray *)allTransitions
{
    return self.transitions;
}

- (BOOL)isValidCommandSequence:(NSArray *)commands
{
    id modelState = self.initialModelState;
    for (PBTCommand *command in commands) {
        id<PBTStateTransition> transition = command.transition;
        id generatedValue = command.generatedValue;
        if (![transition satisfiesPreConditionForModelState:modelState]) {
            return NO;
        }
        modelState = [transition nextModelStateFromModelState:modelState generatedValue:generatedValue];
    }
    return YES;
}

- (BOOL)validateCommandSequence:(NSArray *)commands initialActualState:(id)initialActualState
{
    id modelState = self.initialModelState;
    id actualState = initialActualState;
    for (PBTCommand *command in commands) {
        id<PBTStateTransition> transition = command.transition;
        id generatedValue = command.generatedValue;
        id previousModalState = modelState;

        if ([transition respondsToSelector:@selector(satisfiesPreConditionForModelState:)]) {
            if (![transition satisfiesPreConditionForModelState:modelState]) {
                return NO;
            }
        }
        modelState = [transition nextModelStateFromModelState:modelState generatedValue:generatedValue];
        id resultingValue = [transition objectFromAdvancingActualState:actualState generatedValue:generatedValue];

        if ([transition respondsToSelector:@selector(satisfiesPostConditionInModelState:fromModelState:actualState:generatedValue:returnedObjectFromAdvancing:)]) {
            if (![transition satisfiesPostConditionInModelState:modelState
                                                 fromModelState:previousModalState
                                                    actualState:actualState
                                                 generatedValue:generatedValue
                                    returnedObjectFromAdvancing:resultingValue]) {
                return NO;
            }
        }

    }
    return YES;
}

@end

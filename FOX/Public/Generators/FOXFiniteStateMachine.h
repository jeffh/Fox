#import "FOXStateMachine.h"


@protocol FOXStateTransition;


@interface FOXFiniteStateMachine : NSObject <FOXStateMachine>

- (instancetype)initWithInitialModelState:(id)initialModelState;
- (void)addTransition:(id<FOXStateTransition>)transition;

@end

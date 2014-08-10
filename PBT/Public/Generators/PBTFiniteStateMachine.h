#import "PBTStateMachine.h"


@protocol PBTStateTransition;


@interface PBTFiniteStateMachine : NSObject <PBTStateMachine>

- (instancetype)initWithInitialModelState:(id)initialModelState;
- (void)addTransition:(id<PBTStateTransition>)transition;

@end

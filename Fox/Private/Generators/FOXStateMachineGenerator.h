#import "FOXGenerator.h"

@protocol FOXStateMachine;

@interface FOXStateMachineGenerator : NSObject <FOXGenerator>

- (instancetype)initWithStateMachine:(id<FOXStateMachine>)stateMachine;
- (instancetype)initWithStateMachine:(id<FOXStateMachine>)stateMachine
                   initialModelState:(id)modelState
                             minSize:(NSNumber *)minSize
                             maxSize:(NSNumber *)maxSize;

@end

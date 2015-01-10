#import "FOXMacros.h"


@protocol FOXStateMachine <NSObject>

- (id)initialModelState;
- (NSArray *)allTransitions; // FOXStateTransitions
- (id)modelStateFromCommandSequence:(NSArray *)commands startingModelState:(id)modelState;
- (NSArray *)executeCommandSequence:(NSArray *)commands subject:(id)subject startingModelState:(id)modelState;

// Deprecated methods

@optional
- (id)modelStateFromCommandSequence:(NSArray *)commands
FOX_DEPRECATED("Use -[modelStateFromCommandSequence:startingModelState:] instead.");

@optional
- (NSArray *)executeCommandSequence:(NSArray *)commands
                            subject:(id)subject
FOX_DEPRECATED("Use -[executeCommandSequence:subject:startingModelState:] instead.");

@end

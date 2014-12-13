#import <Foundation/Foundation.h>


@protocol FOXStateMachine <NSObject>

- (id)initialModelState;
- (NSArray *)allTransitions; // FOXStateTransitions
- (id)modelStateFromCommandSequence:(NSArray *)commands; // FOXCommands
- (id)modelStateFromCommandSequence:(NSArray *)commands startingModelState:(id)modelState;
- (NSArray *)executeCommandSequence:(NSArray *)commands subject:(id)subject;
- (NSArray *)executeCommandSequence:(NSArray *)commands subject:(id)subject startingModelState:(id)modelState;

@end

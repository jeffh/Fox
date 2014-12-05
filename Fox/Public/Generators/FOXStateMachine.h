#import <Foundation/Foundation.h>


@protocol FOXStateMachine<NSObject>

- (id)initialModelState;
- (NSArray *)allTransitions; // FOXStateTransitions
- (BOOL)isValidCommandSequence:(NSArray *)commands; // FOXCommands
- (NSArray *)executeCommandSequence:(NSArray *)commands subject:(id)subject;

@end

#import <Foundation/Foundation.h>


@protocol PBTStateMachine <NSObject>

- (id)initialModelState;
- (NSArray *)allTransitions; // PBTStateTransitions
- (BOOL)isValidCommandSequence:(NSArray *)commands; // PBTCommands
- (NSArray *)executeCommandSequence:(NSArray *)commands initialActualState:(id)initialActualState;

@end

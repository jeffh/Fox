#import "FOXCommand.h"


/*! Represents a command that has executed in a state machine.
 *  It stores all the data about the execution by the state machine.
 */
@interface FOXExecutedCommand : NSObject

@property (nonatomic) FOXCommand *command;
@property (nonatomic) NSTimeInterval timeExecuted;
@property (nonatomic) BOOL satisfiesPrecondition;
@property (nonatomic) BOOL satisfiesPostcondition;
@property (nonatomic) id objectReturnedBySubject;
@property (nonatomic) id modelStateBeforeExecution;
@property (nonatomic) id modelStateAfterExecution;
@property (nonatomic) NSException *raisedException;

- (BOOL)wasSuccessfullyExecuted;

@end

#import "FOXCommand.h"

@interface FOXExecutedCommand : NSObject

@property (nonatomic) FOXCommand *command;
@property (nonatomic) NSDate *dateExecuted;
@property (nonatomic) BOOL satisfiesPrecondition;
@property (nonatomic) BOOL satisfiesPostcondition;
@property (nonatomic) id objectReturnedBySubject;
@property (nonatomic) id modelStateBeforeExecution;
@property (nonatomic) id modelStateAfterExecution;
@property (nonatomic) NSException *raisedException;

- (BOOL)wasSuccessfullyExecuted;

@end

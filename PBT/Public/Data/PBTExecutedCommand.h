#import "PBTCommand.h"

@interface PBTExecutedCommand : NSObject

@property (nonatomic) PBTCommand *command;
@property (nonatomic) NSDate *dateExecuted;
@property (nonatomic) BOOL satisfiesPrecondition;
@property (nonatomic) BOOL satisfiesPostcondition;
@property (nonatomic) id objectFromAdvancingActualState;
@property (nonatomic) id modelStateBeforeExecution;
@property (nonatomic) id modelStateAfterExecution;
@property (nonatomic) NSException *raisedException;

- (BOOL)wasSuccessfullyExecuted;

@end

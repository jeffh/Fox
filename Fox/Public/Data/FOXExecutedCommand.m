#import "FOXExecutedCommand.h"

@implementation FOXExecutedCommand

- (BOOL)wasSuccessfullyExecuted
{
    return self.satisfiesPrecondition && self.satisfiesPostcondition;
}

- (NSString *)description
{
    if ([self wasSuccessfullyExecuted]) {
        return [NSString stringWithFormat:@"[subject %@] -> %@",
                                          self.command,
                                          self.objectReturnedBySubject];
    } else {
        return [NSString stringWithFormat:@"[subject %@] -> %@%@%@%@\n    Model before: %@\n    Model after: %@",
                                          self.command,
                                          self.objectReturnedBySubject,
                                          self.satisfiesPrecondition ? @"" : @" (Precondition FAILED)",
                                          self.satisfiesPostcondition ? @"" : @" (Postcondition FAILED)",
                                          self.raisedException ? [NSString stringWithFormat:@"\n    Exception Raised: %@",
                                                                                            self.raisedException] : @"",
                                          self.modelStateBeforeExecution,
                                          self.modelStateAfterExecution];
    }
}

@end

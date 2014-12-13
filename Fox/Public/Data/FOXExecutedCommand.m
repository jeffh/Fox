#import "FOXExecutedCommand.h"

@implementation FOXExecutedCommand

- (BOOL)wasSuccessfullyExecuted
{
    return self.satisfiesPrecondition && self.satisfiesPostcondition;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]){
        return NO;
    }

    FOXExecutedCommand *other = object;
    return ((self.command == other.command || [self.command isEqual:other.command])
            && self.satisfiesPostcondition == other.satisfiesPostcondition
            && self.satisfiesPrecondition == other.satisfiesPrecondition
            && (self.objectReturnedBySubject == other.objectReturnedBySubject
                || [self.objectReturnedBySubject isEqual:other.objectReturnedBySubject])
            && (self.raisedException == other.raisedException
                || [self.raisedException isEqual:other.raisedException]));
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

#import "FOXPropertyGenerators.h"


@implementation FOXPropertyResult

- (BOOL)hasFailedOrRaisedException
{
    return self.status == FOXPropertyStatusFailed
        || self.status == FOXPropertyStatusUncaughtException;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    FOXPropertyResult *other = object;

    return self.status == other.status && self.generatedValue == other.generatedValue;
}

- (NSUInteger)hash
{
    return self.status ^ [self.generatedValue hash];
}

- (NSString *)statusString
{
    switch (self.status) {
        case FOXPropertyStatusFailed:
            return @"Failed";
        case FOXPropertyStatusPassed:
            return @"Passed";
        case FOXPropertyStatusSkipped:
            return @"Skipped";
        case FOXPropertyStatusUncaughtException:
            return @"Uncaught Exception";
    }
}

- (NSString *)generatedValueOrException
{
    if (self.status == FOXPropertyStatusUncaughtException) {
        return [self.uncaughtException description];
    }
    return [self.generatedValue description];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>",
            [self statusString], [self generatedValueOrException]];
}

@end

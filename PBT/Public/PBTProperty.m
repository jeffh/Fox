#import "PBTProperty.h"
#import "PBTGenerator.h"
#import "PBTSequence.h"


@implementation PBTProperty

+ (id<PBTGenerator>)forAll:(id<PBTGenerator>)generator
                      then:(PBTPropertyStatus (^)(id))verifier
{
    return PBTMap(generator, ^id(id value) {
        PBTPropertyResult *result = [[PBTPropertyResult alloc] init];
        result.generatedValue = value;
        @try {
            result.status = verifier(value);
        }
        @catch (NSException *exception) {
            result.uncaughtException = exception;
            result.status = PBTPropertyStatusUncaughtException;
        }
        return result;
    });
}

@end


@implementation PBTPropertyResult

- (BOOL)hasFailedOrRaisedException
{
    return self.status == PBTPropertyStatusFailed
        || self.status == PBTPropertyStatusUncaughtException;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    PBTPropertyResult *other = object;

    return self.status == other.status && self.generatedValue == other.generatedValue;
}

- (NSUInteger)hash
{
    return self.status ^ [self.generatedValue hash];
}

- (NSString *)statusString
{
    switch (self.status) {
        case PBTPropertyStatusFailed:
            return @"Failed";
        case PBTPropertyStatusPassed:
            return @"Passed";
        case PBTPropertyStatusSkipped:
            return @"Skipped";
        case PBTPropertyStatusUncaughtException:
            return @"Uncaught Exception";
    }
}

- (NSString *)generatedValueOrException
{
    if (self.status == PBTPropertyStatusUncaughtException) {
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

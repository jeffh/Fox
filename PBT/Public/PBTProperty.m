#import "PBTProperty.h"
#import "PBTGenerator.h"
#import "PBTSequence.h"


@implementation PBTProperty

+ (id<PBTGenerator>)forAll:(id<PBTGenerator>)generator
                      then:(PBTPropertyStatus (^)(id))verifier
{
    return PBTMap(generator, ^id(id value) {
        PBTPropertyResult *result = [[PBTPropertyResult alloc] init];
        result.status = verifier(value);
        result.generatedValue = value;
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Result: %@ %@>", self.generatedValue, [self statusString]];
}

@end

#import "PBTProperty.h"
#import "PBTGenerator.h"
#import "PBTSequence.h"


@implementation PBTProperty

+ (PBTGenerator)forAll:(PBTGenerator)generator
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

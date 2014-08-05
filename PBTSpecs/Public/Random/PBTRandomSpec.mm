#import "PBTRandom.h"
#import "PBTSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTRandomSpec)

describe(@"PBTRandom", ^{
    it(@"should produce the same random sequence for the same seed", ^{
        PBTQuickCheckResult *result = [PBTSpecHelper resultForAll:PBTInteger() then:^BOOL(NSNumber *value) {
            PBTRandom *random1 = [[PBTRandom alloc] initWithSeed:(uint32_t)[value integerValue]];
            PBTRandom *random2 = [[PBTRandom alloc] initWithSeed:(uint32_t)[value integerValue]];
            BOOL equalRandInts = [random1 randomInteger] == [random2 randomInteger];
            NSUInteger actual = [random1 randomIntegerWithinMinimum:5 andMaximum:1000];
            return equalRandInts && (actual == [random2 randomIntegerWithinMinimum:5 andMaximum:1000]);
        }];
        result should be_truthy;
    });

    it(@"should produce different values when no seed is specified", ^{
        PBTQuickCheckResult *result = [PBTSpecHelper resultForAll:PBTInteger() then:^BOOL(NSNumber *value) {
            PBTRandom *random1 = [[PBTRandom alloc] init];
            PBTRandom *random2 = [[PBTRandom alloc] init];
            BOOL equalRandInts = [random1 randomInteger] != [random2 randomInteger];
            NSUInteger actual = [random1 randomIntegerWithinMinimum:5 andMaximum:1000];
            return equalRandInts || (actual != [random2 randomIntegerWithinMinimum:5 andMaximum:1000]);
        }];
        result should be_truthy;
    });
});

SPEC_END

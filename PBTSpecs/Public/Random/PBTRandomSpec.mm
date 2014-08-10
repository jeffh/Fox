#import "PBTDeterministicRandom.h"
#import "PBTSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTRandomSpec)

describe(@"PBTDeterministicRandom", ^{
    it(@"should produce the same random sequence for the same seed", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTInteger() then:^BOOL(NSNumber *value) {
            PBTDeterministicRandom *random1 = [[PBTDeterministicRandom alloc] initWithSeed:(uint32_t)[value integerValue]];
            PBTDeterministicRandom *random2 = [[PBTDeterministicRandom alloc] initWithSeed:(uint32_t)[value integerValue]];
            BOOL equalRandInts = [random1 randomInteger] == [random2 randomInteger];
            NSUInteger actual = [random1 randomIntegerWithinMinimum:5 andMaximum:1000];
            return equalRandInts && (actual == [random2 randomIntegerWithinMinimum:5 andMaximum:1000]);
        }];
        result should be_truthy;
    });

    it(@"should produce different values when no seed is specified", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTInteger() then:^BOOL(NSNumber *value) {
            PBTDeterministicRandom *random1 = [[PBTDeterministicRandom alloc] init];
            PBTDeterministicRandom *random2 = [[PBTDeterministicRandom alloc] init];
            BOOL equalRandInts = [random1 randomInteger] != [random2 randomInteger];
            NSUInteger actual = [random1 randomIntegerWithinMinimum:5 andMaximum:1000];
            return equalRandInts || (actual != [random2 randomIntegerWithinMinimum:5 andMaximum:1000]);
        }];
        result should be_truthy;
    });
});

SPEC_END

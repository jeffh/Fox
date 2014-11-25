#import <Cedar/Cedar.h>
#import "FOXDeterministicRandom.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXRandomSpec)

describe(@"FOXDeterministicRandom", ^{
    it(@"should produce the same random sequence for the same seed", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXInteger() then:^BOOL(NSNumber *value) {
            FOXDeterministicRandom *random1 = [[FOXDeterministicRandom alloc] initWithSeed:(uint32_t)[value integerValue]];
            FOXDeterministicRandom *random2 = [[FOXDeterministicRandom alloc] initWithSeed:(uint32_t)[value integerValue]];
            BOOL equalRandInts = [random1 randomInteger] == [random2 randomInteger];
            NSUInteger actual = [random1 randomIntegerWithinMinimum:5 andMaximum:1000];
            return equalRandInts && (actual == [random2 randomIntegerWithinMinimum:5 andMaximum:1000]);
        }];
        result should be_truthy;
    });

    it(@"should produce different values when no seed is specified", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXInteger() then:^BOOL(NSNumber *value) {
            FOXDeterministicRandom *random1 = [[FOXDeterministicRandom alloc] init];
            FOXDeterministicRandom *random2 = [[FOXDeterministicRandom alloc] init];
            BOOL equalRandInts = [random1 randomInteger] != [random2 randomInteger];
            NSUInteger actual = [random1 randomIntegerWithinMinimum:5 andMaximum:1000];
            return equalRandInts || (actual != [random2 randomIntegerWithinMinimum:5 andMaximum:1000]);
        }];
        result should be_truthy;
    });
});

SPEC_END

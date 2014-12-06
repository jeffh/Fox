#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXFloatSpec)

describe(@"FOXFloat", ^{
    it(@"should generate non-integers", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFloat() then:^BOOL(NSNumber *value) {
            return fmodf([value floatValue], 1) == 0;
        }];
        result.succeeded should be_falsy;
    });

    it(@"should shrink towards zero", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFloat() then:^BOOL(id value) {
            return NO;
        }];

        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@0);
    });

    it(@"should never shrink to a value further from zero", ^{
        NSArray *values = FOXSampleShrinkingWithCount(FOXFloat(), 5000);
        NSArray *sortedValues = [values sortedArrayUsingSelector:@selector(compare:)];
        if ([values[0] floatValue] > 0) {
            [sortedValues.lastObject floatValue] should equal([values[0] floatValue]);
        } else {
            [sortedValues.firstObject floatValue] should equal([values[0] floatValue]);
        }
    });

    it(@"should shrink using smaller divisors and dividends", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFloat() then:^BOOL(NSNumber *value) {
            return fmodf([value floatValue], 1) == 0;
        }];
        result.succeeded should be_falsy;
        ABS([result.smallestFailingValue floatValue]) should be_less_than_or_equal_to(1);
    });

    it(@"should shrink negative values to zero", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFloat() then:^BOOL(NSNumber *value) {
            return [value floatValue] >= 0;
        }];

        result.succeeded should be_falsy;
        result.smallestFailingValue should be_greater_than_or_equal_to(@(-1));
    });
});

SPEC_END

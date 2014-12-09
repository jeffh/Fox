#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"
#import "FOXChooseGenerator.h"

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
        NSArray *values = FOXSampleShrinkingWithCount(FOXFloat(), 100);
        float originalValue = [values[0] floatValue];
        for (NSNumber *value in values) {
            ABS([value floatValue]) should be_less_than_or_equal_to(ABS(originalValue));
        }
    });

    it(@"should shrink to smaller exponents if whole integers are not valid", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFloat() then:^BOOL(NSNumber *value) {
            return fmodf([value floatValue], 1) == 0;
        }];
        result.succeeded should be_falsy;
        ABS([result.smallestFailingValue floatValue]) should be_less_than_or_equal_to(0.001);
    });

    it(@"should shrink negative values to zero", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFloat() then:^BOOL(NSNumber *value) {
            return [value floatValue] >= 0;
        }];

        result.succeeded should be_falsy;
        result.smallestFailingValue should be_greater_than_or_equal_to(@(-0.001));
    });
});

SPEC_END

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

    it(@"should generate NaN", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXResize(FOXFloat(), NSUIntegerMax) then:^BOOL(NSNumber *generatedValue) {
            return !isnan([generatedValue floatValue]);
        } numberOfTests:10000];
        result.succeeded should be_falsy;
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

describe(@"FOXFamousFloat", ^{
    it(@"should generate min, max, and exceptional values regularly", ^{
        __block BOOL hasSeenNaN = NO;
        __block BOOL hasSeenNegZero = NO;
        __block BOOL hasSeenPosInf = NO;
        __block BOOL hasSeenNegInf = NO;
        __block BOOL hasSeenMin = NO;
        __block BOOL hasSeenMax = NO;
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFamousFloat() then:^BOOL(NSNumber *value) {
            float val = [value floatValue];
            if (isnan(val)) {
                hasSeenNaN = YES;
                return YES;
            }
            hasSeenNegZero = hasSeenNegZero || [value isEqual:@(-0.f)];
            hasSeenMax = hasSeenMax || [value isEqual:@(FLT_MAX)];
            hasSeenMin = hasSeenMax || [value isEqual:@(-FLT_MAX)];
            hasSeenPosInf = hasSeenPosInf || [value isEqual:@(INFINITY)];
            hasSeenNegInf = hasSeenNegInf || [value isEqual:@(-INFINITY)];
            return YES;
        }];

        hasSeenNaN should be_truthy;
        hasSeenNegZero should be_truthy;
        hasSeenMax should be_truthy;
        hasSeenMin should be_truthy;
        hasSeenPosInf should be_truthy;
        hasSeenNegInf should be_truthy;
        result should be_truthy;
    });
});

SPEC_END

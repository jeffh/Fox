#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"
#import <limits.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXDoubleSpec)

describe(@"FOXDouble", ^{
    it(@"should generate non-integers", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXDouble() then:^BOOL(NSNumber *value) {
            return fmod([value doubleValue], 1) == 0;
        }];
        result.succeeded should be_falsy;
    });

    it(@"should shrink towards zero", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXDouble() then:^BOOL(id value) {
            return NO;
        }];

        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@0);
    });

    it(@"should never shrink to a value further from zero", ^{
        NSArray *values = FOXSampleShrinkingWithCount(FOXDouble(), 100);
        NSNumber *originalValue = values[0];
        for (NSNumber *value in values) {
            ABS([value doubleValue]) should be_less_than_or_equal_to(ABS([originalValue doubleValue]));
        }
    });

    it(@"should shrink to smaller exponents if whole integers are not valid", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXDouble() then:^BOOL(NSNumber *value) {
            return fmod([value doubleValue], 1) == 0;
        }];
        result.succeeded should be_falsy;
        ABS([result.smallestFailingValue doubleValue]) should be_less_than_or_equal_to(0.00000001);
    });

    it(@"should shrink negative values to zero", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXDouble() then:^BOOL(NSNumber *value) {
            return [value doubleValue] >= 0;
        }];

        result.succeeded should be_falsy;
        result.smallestFailingValue should be_greater_than_or_equal_to(@(-0.00000001));
    });
});


describe(@"FOXFamousDouble", ^{
    it(@"should generate min, max, and exceptional values regularly", ^{
        __block BOOL hasSeenNaN = NO;
        __block BOOL hasSeenNegZero = NO;
        __block BOOL hasSeenPosInf = NO;
        __block BOOL hasSeenNegInf = NO;
        __block BOOL hasSeenMin = NO;
        __block BOOL hasSeenMax = NO;
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFamousDouble() then:^BOOL(NSNumber *value) {
            double val = [value doubleValue];
            if (isnan(val)) {
                hasSeenNaN = YES;
                return YES;
            }
            hasSeenNegZero = hasSeenNegZero || [value isEqual:@(-0.f)];
            hasSeenMax = hasSeenMax || [value isEqual:@(std::numeric_limits<double>::max())];
            hasSeenMin = hasSeenMax || [value isEqual:@(-std::numeric_limits<double>::max())];
            hasSeenPosInf = hasSeenPosInf || [value isEqual:@(std::numeric_limits<double>::infinity())];
            hasSeenNegInf = hasSeenNegInf || [value isEqual:@(-std::numeric_limits<double>::infinity())];
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

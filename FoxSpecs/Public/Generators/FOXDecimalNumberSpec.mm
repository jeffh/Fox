#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

static NSDecimalNumber *absoluteNumber(NSDecimalNumber *number) {
    NSDecimalNumber *negatedNumber = [number decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
    if ([number compare:negatedNumber] == NSOrderedAscending) {
        return negatedNumber;
    } else {
        return number;
    }
}

static bool isWholeNumber(NSDecimalNumber *number) {
    NSDecimalNumber *zero = [NSDecimalNumber zero];
    if (number.decimalValue._exponent < 0) {
        return NO;
    }
    if ([number compare:zero] == NSOrderedSame) {
        return YES;
    }

    return ![[number description] containsString:@"."];
}

SPEC_BEGIN(FOXDecimalNumberSpec)

describe(@"FOXDecimalNumber", ^{
    it(@"should generate non-integers", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXDecimalNumber() then:^BOOL(NSDecimalNumber *value) {
            return isWholeNumber(value);
        }];
        result.succeeded should be_falsy;
    });

    it(@"should shrink towards zero", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXDecimalNumber() then:^BOOL(id value) {
            return NO;
        }];

        result.succeeded should be_falsy;
        result.smallestFailingValue should equal([NSDecimalNumber zero]);
    });

    it(@"should never shrink to a value further from zero", ^{
        NSArray *values = FOXSampleShrinkingWithCount(FOXDecimalNumber(), 100);
        NSDecimalNumber *originalValue = values[0];
        for (NSDecimalNumber *value in values) {
            absoluteNumber(value) should be_less_than_or_equal_to(absoluteNumber(originalValue));
        }
    });

    it(@"should shrink to smaller exponents if whole integers are not valid", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXDecimalNumber() then:^BOOL(NSDecimalNumber *value) {
            return isWholeNumber(value);
        }];
        result.succeeded should be_falsy;
        NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"0.00000001"];
        absoluteNumber(result.smallestFailingValue) should be_less_than_or_equal_to(number);
    });

    it(@"should shrink negative values to zero", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXDecimalNumber() then:^BOOL(NSDecimalNumber *value) {
            NSDecimalNumber *zero = [NSDecimalNumber zero];
            return [value compare:zero] == NSOrderedAscending;
        }];

        result.succeeded should be_falsy;
        NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"-0.00000001"];
        result.smallestFailingValue should be_greater_than_or_equal_to(number);
    });
});

describe(@"FOXFamousDecimalNumber", ^{
    it(@"should generate min, max, and NaN regularly", ^{
        __block BOOL hasSeenNaN = NO;
        __block BOOL hasSeenMin = NO;
        __block BOOL hasSeenMax = NO;
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFamousDecimalNumber() then:^BOOL(NSDecimalNumber *value) {
            hasSeenNaN = hasSeenNaN || [value isEqual:[NSDecimalNumber notANumber]];
            hasSeenMax = hasSeenMax || [value isEqual:[NSDecimalNumber maximumDecimalNumber]];
            hasSeenMin = hasSeenMax || [value isEqual:[NSDecimalNumber minimumDecimalNumber]];
            return YES;
        }];

        hasSeenNaN should be_truthy;
        hasSeenMax should be_truthy;
        hasSeenMin should be_truthy;
        result should be_truthy;
    });
});

SPEC_END

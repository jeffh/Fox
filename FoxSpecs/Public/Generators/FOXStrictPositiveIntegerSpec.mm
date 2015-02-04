#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXStrictPositiveIntegerSpec)

describe(@"FOXStrictPositiveInteger", ^{
    it(@"should generate positive numbers, excluding zero", ^{
        FOXAssert(FOXForAll(FOXStrictPositiveInteger(), ^BOOL(NSNumber *value) {
            return [value integerValue] > 0;
        }));
    });

    it(@"should shrink to 1", ^{
        FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXStrictPositiveInteger()];

        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@1);
    });
});

describe(@"FOXFamousStrictPositiveInteger", ^{
    it(@"should generate INT_MAX more frequently", ^{
        __block BOOL hasSeenIntMax = NO;
        FOXAssert(FOXForAll(FOXFamousStrictPositiveInteger(), ^BOOL(NSNumber *value) {
            hasSeenIntMax = hasSeenIntMax || [value integerValue] == INT_MAX;
            return [value integerValue] > 0;
        }));

        hasSeenIntMax should be_truthy;
    });

    it(@"should generate positive numbers, excluding zero", ^{
        FOXAssert(FOXForAll(FOXFamousStrictPositiveInteger(), ^BOOL(NSNumber *value) {
            return [value integerValue] > 0;
        }));
    });

    it(@"should shrink to 1", ^{
        FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXFamousStrictPositiveInteger()];

        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@1);
    });
});

SPEC_END

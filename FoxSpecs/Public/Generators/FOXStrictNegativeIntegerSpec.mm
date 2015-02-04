#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXStrictNegativeIntegerSpec)

describe(@"FOXStrictNegativeInteger", ^{
    it(@"should generate negative numbers, excluding zero", ^{
        FOXAssert(FOXForAll(FOXStrictNegativeInteger(), ^BOOL(NSNumber *value) {
            return [value integerValue] < 0;
        }));
    });

    it(@"should shrink to -1", ^{
        FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXStrictNegativeInteger()];

        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@(-1));
    });
});

describe(@"FOXFamousStrictNegativeInteger", ^{
    it(@"should generate INT_MIN more frequently", ^{
        __block BOOL hasSeenIntMin = NO;
        FOXAssert(FOXForAll(FOXFamousStrictNegativeInteger(), ^BOOL(NSNumber *value) {
            hasSeenIntMin = hasSeenIntMin || [value integerValue] == INT_MIN;
            return [value integerValue] < 0;
        }));

        hasSeenIntMin should be_truthy;
    });

    it(@"should generate negative numbers, excluding zero", ^{
        FOXAssert(FOXForAll(FOXFamousStrictNegativeInteger(), ^BOOL(NSNumber *value) {
            return [value integerValue] < 0;
        }));
    });
});

SPEC_END

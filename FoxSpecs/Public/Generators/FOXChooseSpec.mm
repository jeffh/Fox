#import <Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXChooseSpec)

describe(@"FOXChoose", ^{
    it(@"should be within a given range (inclusive)", ^{
        FOXAssert(FOXForAll(FOXChoose(@0, @10), ^BOOL(id value) {
            return [value integerValue] >= 0 && [value integerValue] <= 10;
        }));
    });

    it(@"should shrink to the smallest number", ^{
        FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXChoose(@0, @10)];

        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@0);
    });
});

SPEC_END

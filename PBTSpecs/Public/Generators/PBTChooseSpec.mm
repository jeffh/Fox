#import "PBT.h"
#import "PBTSpecHelper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTChooseSpec)

describe(@"PBTChoose", ^{
    it(@"should be within a given range (inclusive)", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTChoose(@0, @10) then:^BOOL(NSNumber *value) {
            return [value integerValue] >= 0 && [value integerValue] <= 10;
        }];

        result.succeeded should be_truthy;
    });

    it(@"should shrink to the smallest number", ^{
        PBTRunnerResult *result = [PBTSpecHelper shrunkResultForAll:PBTChoose(@0, @10)];

        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@0);
    });
});

SPEC_END

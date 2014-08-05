#import "PBT.h"
#import "PBTSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTReturnSpec)

describe(@"PBTReturn", ^{
    it(@"should only generate the given value", ^{
        __block id capturedValue;
        PBTQuickCheckResult *result = [PBTSpecHelper resultForAll:PBTReturn(@1) then:^BOOL(id value) {
            capturedValue = value;
            return YES;
        }];

        result.succeeded should be_truthy;
        capturedValue should equal(@1);
    });

    it(@"should never shrink", ^{
        PBTQuickCheckResult *result = [PBTSpecHelper resultForAll:PBTReturn(@1) then:^BOOL(id value) {
            return NO;
        }];

        result.succeeded should be_falsy;
        result.smallestFailingArguments should equal(@1);
    });
});

SPEC_END

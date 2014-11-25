#import <Cedar/Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXReturnSpec)

describe(@"FOXReturn", ^{
    it(@"should only generate the given value", ^{
        __block id capturedValue;
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXReturn(@1) then:^BOOL(id value) {
            capturedValue = value;
            return YES;
        }];

        result.succeeded should be_truthy;
        capturedValue should equal(@1);
    });

    it(@"should never shrink", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXReturn(@1) then:^BOOL(id value) {
            return NO;
        }];

        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@1);
    });
});

SPEC_END

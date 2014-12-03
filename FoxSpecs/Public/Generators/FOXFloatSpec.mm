#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXFloatSpec)

describe(@"FOXFloat", ^{
    context(@"integration", ^{
        it(@"should generate non-integers", ^{
            FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFloat() then:^BOOL(NSNumber *value) {
                return fmodf([value floatValue], 1) == 0;
            }];
            result.succeeded should be_falsy;
        });

        it(@"should shrink towards zero", ^{
            FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXFloat()];

            result.succeeded should be_falsy;
            result.smallestFailingValue should equal(@0);
        });

        it(@"should shrink negative values to zero", ^{
            FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFloat() then:^BOOL(NSNumber *value) {
                return [value floatValue] >= 0;
            }];

            result.succeeded should be_falsy;
            result.smallestFailingValue should equal(@(-1));
        });
    });
});

SPEC_END

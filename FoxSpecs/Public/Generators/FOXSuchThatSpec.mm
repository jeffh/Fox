#import <Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXSuchThatSpec)

describe(@"FOXSuchThat", ^{
    it(@"should filter values from a predicate", ^{
        id<FOXGenerator> generator = FOXSuchThat(FOXInteger(), ^BOOL(NSNumber *generatedValue) {
            return [generatedValue integerValue] % 2 == 0;
        });

        FOXRunnerResult * result = [FOXSpecHelper resultForAll:generator then:^BOOL(NSNumber *value) {
            return [value integerValue] % 2 == 0;
        }];
        result.succeeded should be_truthy;
    });
});

SPEC_END

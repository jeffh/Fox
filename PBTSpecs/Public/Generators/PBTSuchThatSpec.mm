#import <Cedar/Cedar.h>
#import "PBT.h"
#import "PBTSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTSuchThatSpec)

describe(@"PBTSuchThat", ^{
    it(@"should filter values from a predicate", ^{
        id<PBTGenerator> generator = PBTSuchThat(PBTInteger(), ^BOOL(NSNumber *generatedValue) {
            return [generatedValue integerValue] % 2 == 0;
        });

        PBTRunnerResult * result = [PBTSpecHelper resultForAll:generator then:^BOOL(NSNumber *value) {
            return [value integerValue] % 2 == 0;
        }];
        result.succeeded should be_truthy;
    });
});

SPEC_END

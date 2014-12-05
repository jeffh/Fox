#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXResizeSpec)

describe(@"FOXResize", ^{
    id<FOXGenerator> generator = FOXGenerate(^FOXRoseTree *(id<FOXRandom> random, NSUInteger size) {
        return [[FOXRoseTree alloc] initWithValue:@(size)];
    });

    context(@"integration", ^{
        it(@"should not shrink", ^{
            FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXResize(10, generator)];

            result.succeeded should be_falsy;
            result.smallestFailingValue should equal(@10);
        });
    });
});
SPEC_END

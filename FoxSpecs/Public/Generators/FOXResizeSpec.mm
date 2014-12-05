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

    it(@"should not shrink", ^{
        FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXResize(generator, 10)];

        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@10);
    });
});

SPEC_END

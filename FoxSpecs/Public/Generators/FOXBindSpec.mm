#import <Cedar.h>
#import "Fox.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXBindSpec)

describe(@"FOXBind", ^{
    it(@"should no-op if the binding block only returns", ^{
        id<FOXGenerator> originalGenerator = FOXResize(FOXChoose(@0, @3), 5);
        id<FOXGenerator> bindedGenerator = FOXBind(originalGenerator, ^id<FOXGenerator>(id generatedValue) {
            return FOXReturn(generatedValue);
        });
        id<FOXRandom> random = [[FOXConstantRandom alloc] initWithValue:2];
        FOXRoseTree *tree = [bindedGenerator lazyTreeWithRandom:random maximumSize:50];
        FOXRoseTree *expectedTree = [originalGenerator lazyTreeWithRandom:random maximumSize:50];
        tree should equal(expectedTree);
    });
});

SPEC_END

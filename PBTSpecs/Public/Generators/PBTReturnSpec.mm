#import "PBT.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTReturnSpec)

describe(@"PBTReturn", ^{
    it(@"should always return the given value", ^{
        for (NSUInteger i = 0; i < 10; i++) {
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithValue:i];
            PBTRoseTree *tree = [PBTReturn(@1) lazyTreeWithRandom:random maximumSize:i];
            tree should equal([PBTRoseTree treeFromArray:@[@1, @[]]]);
        }
    });
});

SPEC_END

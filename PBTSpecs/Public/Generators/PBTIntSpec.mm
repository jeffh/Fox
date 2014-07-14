#import "PBT.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTIntSpec)

describe(@"PBTInt", ^{
    context(@"when the randomizer returns zero", ^{
        it(@"should return an number within the range generated", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithDoubleValue:0];
            PBTRoseTree *tree = PBTInt()(random, @0);
            tree should equal([PBTRoseTree treeFromArray:@[@0, @[]]]);
        });
    });

    context(@"when the randomizer returns 1", ^{
        it(@"should return an number within the range generated [-1, 1]", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithDoubleValue:1];
            PBTRoseTree *tree = PBTInt()(random, @1);
            tree should equal([PBTRoseTree treeFromArray:@[@1, @[@[@0, @[]]]]]);
        });
    });

    context(@"when the randomizer returns -2", ^{
        it(@"should return an number within the range generated [-2, 2]", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithDoubleValue:-2];
            PBTRoseTree *tree = PBTInt()(random, @(2));
            tree should equal([PBTRoseTree treeFromArray:@[@(-2), @[@[@0, @[]],
                                                                    @[@(-1), @[@[@0, @[]]]]]]]);
        });
    });
});

SPEC_END

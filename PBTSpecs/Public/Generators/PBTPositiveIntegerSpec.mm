#import "PBT.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTPositiveIntegerSpec)

describe(@"PBTPositiveInteger", ^{
    context(@"when the randomizer returns zero", ^{
        it(@"should return an number within the range generated", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithValue:0];
            PBTRoseTree *tree = [PBTPositiveInteger() lazyTreeWithRandom:random maximumSize:0];
            tree should equal([PBTRoseTree treeFromArray:@[@0, @[]]]);
        });
    });

    context(@"when the randomizer returns -1", ^{
        it(@"should return an number within the range generated [0, 1]", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithValue:-1];
            PBTRoseTree *tree = [PBTPositiveInteger() lazyTreeWithRandom:random maximumSize:1];
            tree should equal([PBTRoseTree treeFromArray:@[@1, @[@[@0, @[]]]]]);
        });
    });

    context(@"when the randomizer returns -2", ^{
        it(@"should return an number within the range generated [0, 2]", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithValue:-2];
            PBTRoseTree *tree = [PBTPositiveInteger() lazyTreeWithRandom:random maximumSize:2];
            tree should equal([PBTRoseTree treeFromArray:@[@(2), @[@[@0, @[]],
                                                                   @[@(1), @[@[@0, @[]]]]]]]);
        });
    });
});

SPEC_END

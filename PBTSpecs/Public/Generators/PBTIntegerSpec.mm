#import "PBT.h"
#import "PBTSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTIntegerSpec)

describe(@"PBTInteger", ^{
    it(@"should be within a given range (inclusive)", ^{
        PBTQuickCheckResult *result = [PBTSpecHelper resultForAll:PBTChoose(@0, @10) then:^BOOL(NSNumber *value) {
            return [value integerValue] >= 0 && [value integerValue] <= 10;
        }];
        result.succeeded should be_truthy;
    });

    context(@"when the randomizer returns zero", ^{
        it(@"should return an number within the range generated", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithValue:0];
            PBTRoseTree *tree = [PBTInteger() lazyTreeWithRandom:random maximumSize:0];
            tree should equal([PBTRoseTree treeFromArray:@[@0, @[]]]);
        });
    });

    context(@"when the randomizer returns 1", ^{
        it(@"should return an number within the range generated [-1, 1]", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithValue:1];
            PBTRoseTree *tree = [PBTInteger() lazyTreeWithRandom:random maximumSize:1];
            tree should equal([PBTRoseTree treeFromArray:@[@1, @[@[@0, @[]]]]]);
        });
    });

    context(@"when the randomizer returns -2", ^{
        it(@"should return an number within the range generated [-2, 2]", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithValue:-2];
            PBTRoseTree *tree = [PBTInteger() lazyTreeWithRandom:random maximumSize:2];
            tree should equal([PBTRoseTree treeFromArray:@[@(-2), @[@[@0, @[]],
                                                                    @[@(-1), @[@[@0, @[]]]]]]]);
        });
    });
});

SPEC_END

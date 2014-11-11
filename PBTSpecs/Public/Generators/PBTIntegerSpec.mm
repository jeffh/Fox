#import <Cedar/Cedar.h>
#import "PBT.h"
#import "PBTSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTIntegerSpec)

describe(@"PBTInteger", ^{
    context(@"unit", ^{
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

    context(@"integration", ^{
        it(@"should shrink towards zero", ^{
            PBTRunnerResult *result = [PBTSpecHelper shrunkResultForAll:PBTInteger()];

            result.succeeded should be_falsy;
            result.smallestFailingValue should equal(@0);
        });

        it(@"should shrink negative values to zero", ^{
            PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTInteger() then:^BOOL(NSNumber *value) {
                return [value integerValue] >= 0;
            }];

            result.succeeded should be_falsy;
            result.smallestFailingValue should equal(@(-1));
        });
    });
});

SPEC_END

#import <Cedar/Cedar.h>
#import "PBT.h"
#import "PBTSpecHelper.h"
#import "PBTNumericGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTPositiveIntegerSpec)

describe(@"PBTPositiveInteger", ^{
    context(@"unit test", ^{
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

    context(@"integration", ^{
        it(@"should generate positive numbers", ^{
            PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTPositiveInteger() then:^BOOL(NSNumber *value) {
                return [value unsignedIntegerValue] > 0 || [value unsignedIntegerValue] == 0;
            }];

            result.succeeded should be_truthy;
        });

        it(@"should not generate negative numbers", ^{
            PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTPositiveInteger() then:^BOOL(NSNumber *value) {
                return [value integerValue] >= 0;
            }];

            result.succeeded should be_truthy;
        });

        it(@"should shrink to zero", ^{
            PBTRunnerResult *result = [PBTSpecHelper shrunkResultForAll:PBTPositiveInteger()];

            result.succeeded should be_falsy;
            result.smallestFailingValue should equal(@0);
        });
    });
});

SPEC_END

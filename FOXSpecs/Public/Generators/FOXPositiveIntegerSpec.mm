#import <Cedar/Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"
#import "FOXNumericGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXPositiveIntegerSpec)

describe(@"FOXPositiveInteger", ^{
    context(@"unit test", ^{
        context(@"when the randomizer returns zero", ^{
            it(@"should return an number within the range generated", ^{
                FOXConstantRandom *random = [[FOXConstantRandom alloc] initWithValue:0];
                FOXRoseTree *tree = [FOXPositiveInteger() lazyTreeWithRandom:random maximumSize:0];
                tree should equal([FOXRoseTree treeFromArray:@[@0, @[]]]);
            });
        });

        context(@"when the randomizer returns -1", ^{
            it(@"should return an number within the range generated [0, 1]", ^{
                FOXConstantRandom *random = [[FOXConstantRandom alloc] initWithValue:-1];
                FOXRoseTree *tree = [FOXPositiveInteger() lazyTreeWithRandom:random maximumSize:1];
                tree should equal([FOXRoseTree treeFromArray:@[@1, @[@[@0, @[]]]]]);
            });
        });

        context(@"when the randomizer returns -2", ^{
            it(@"should return an number within the range generated [0, 2]", ^{
                FOXConstantRandom *random = [[FOXConstantRandom alloc] initWithValue:-2];
                FOXRoseTree *tree = [FOXPositiveInteger() lazyTreeWithRandom:random maximumSize:2];
                tree should equal([FOXRoseTree treeFromArray:@[@(2), @[@[@0, @[]],
                    @[@(1), @[@[@0, @[]]]]]]]);
            });
        });
    });

    context(@"integration", ^{
        it(@"should generate positive numbers", ^{
            FOXAssert(FOXForAll(FOXPositiveInteger(), ^BOOL(NSNumber *value) {
                return [value unsignedIntegerValue] > 0 || [value unsignedIntegerValue] == 0;
            }));
        });

        it(@"should not generate negative numbers", ^{
            FOXAssert(FOXForAll(FOXPositiveInteger(), ^BOOL(NSNumber *value) {
                return [value integerValue] >= 0;
            }));
        });

        it(@"should shrink to zero", ^{
            FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXPositiveInteger()];

            result.succeeded should be_falsy;
            result.smallestFailingValue should equal(@0);
        });
    });
});

SPEC_END

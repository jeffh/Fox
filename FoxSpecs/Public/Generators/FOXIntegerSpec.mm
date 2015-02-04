#import <Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXIntegerSpec)

describe(@"FOXInteger", ^{
    context(@"unit", ^{
        context(@"when the randomizer returns zero", ^{
            it(@"should return an number within the range generated", ^{
                FOXConstantRandom *random = [[FOXConstantRandom alloc] initWithValue:0];
                FOXRoseTree *tree = [FOXInteger() lazyTreeWithRandom:random maximumSize:0];
                tree should equal([FOXRoseTree treeFromArray:@[@0, @[]]]);
            });
        });

        context(@"when the randomizer returns 1", ^{
            it(@"should return an number within the range generated [-1, 1]", ^{
                FOXConstantRandom *random = [[FOXConstantRandom alloc] initWithValue:1];
                FOXRoseTree *tree = [FOXInteger() lazyTreeWithRandom:random maximumSize:1];
                tree should equal([FOXRoseTree treeFromArray:@[@1, @[@[@0, @[]]]]]);
            });
        });

        context(@"when the randomizer returns -2", ^{
            it(@"should return an number within the range generated [-2, 2]", ^{
                FOXConstantRandom *random = [[FOXConstantRandom alloc] initWithValue:-2];
                FOXRoseTree *tree = [FOXInteger() lazyTreeWithRandom:random maximumSize:2];
                tree should equal([FOXRoseTree treeFromArray:@[@(-2), @[@[@0, @[]],
                    @[@(-1), @[@[@0, @[]]]]]]]);
            });
        });
    });

    context(@"integration", ^{
        it(@"should shrink towards zero", ^{
            FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXInteger()];

            result.succeeded should be_falsy;
            result.smallestFailingValue should equal(@0);
        });

        it(@"should shrink negative values to zero", ^{
            FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXInteger() then:^BOOL(NSNumber *value) {
                return [value integerValue] >= 0;
            }];

            result.succeeded should be_falsy;
            result.smallestFailingValue should equal(@(-1));
        });
    });
});

describe(@"FOXFamousIntegers", ^{
    it(@"should generate min and max integers", ^{
        __block BOOL hasSeenIntMax = NO;
        __block BOOL hasSeenIntMin = NO;
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXFamousInteger() then:^BOOL(NSNumber *value) {
            hasSeenIntMax = hasSeenIntMax || [value isEqual:@(INT_MAX)];
            hasSeenIntMin = hasSeenIntMin || [value isEqual:@(INT_MIN)];
            return YES;
        }];

        hasSeenIntMax should be_truthy;
        hasSeenIntMin should be_truthy;
        result should be_truthy;
    });
});

SPEC_END

#import "PBT.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#define SEQ(...) [PBTConcreteSequence sequenceFromArray:(@[__VA_ARGS__])]
#define ARR(...) @[__VA_ARGS__]


SPEC_BEGIN(PBTArraySpec)

describe(@"PBTArray", ^{
    context(@"when the randomizer returns zero", ^{
        it(@"should return an number within the range generated", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithDoubleValue:0];
            PBTRoseTree *tree = [PBTArray(PBTInteger()) lazyTreeWithRandom:random maximumSize:0];
            tree should equal([PBTRoseTree treeFromArray:@[SEQ(), @[]]]);
        });
    });

    context(@"when the randomizer returns 1", ^{
        it(@"should return an number within the range generated [0, 1] in side an array", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithDoubleValue:1];
            PBTRoseTree *tree = [PBTArray(PBTInteger()) lazyTreeWithRandom:random maximumSize:1];
            tree should equal([PBTRoseTree treeFromArray:@[SEQ(@1), @[@[SEQ(@0), @[]]]]]);
        });
    });

    context(@"when the randomizer returns 2", ^{
        it(@"should return an number within the range generated [0, 2] in side an array of ", ^{
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithDoubleValue:2];
            PBTRoseTree *tree = [PBTArray(PBTInteger()) lazyTreeWithRandom:random maximumSize:2];
            tree should equal([PBTRoseTree treeFromArray:@[ARR(@2, @2), @[
                                                               @[ARR(@0, @0), @[
                                                                     @[ARR(@1, @1), @[
                                                                           @[ARR(@0, @0), @[]]
                                                                       ]]
                                                                ]]]
                                                           ]]);
        });
    });
});

SPEC_END

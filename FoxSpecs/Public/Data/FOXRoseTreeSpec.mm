#import <Cedar.h>
#import "FOXRoseTree.h"
#import "FOXSequence.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXRoseTreeSpec)

describe(@"FOXRoseTree", ^{
    __block FOXRoseTree *inputTree1;
    __block FOXRoseTree *inputTree2;

    beforeEach(^{
        inputTree1 = [[FOXRoseTree alloc] initWithValue:@1 children:[FOXSequence sequenceWithObject:[[FOXRoseTree alloc] initWithValue:@2]]];
        inputTree2 = [[FOXRoseTree alloc] initWithValue:@3 children:[FOXSequence sequenceWithObject:[[FOXRoseTree alloc] initWithValue:@4]]];
    });

    describe(@"value object", ^{
        it(@"should be copyable", ^{
            inputTree1 should equal([inputTree1 copy]);
        });

        it(@"should be equal to trees with the same value and children", ^{
            inputTree1 should equal(inputTree1);
            inputTree1 should equal([[FOXRoseTree alloc] initWithValue:@1 children:[FOXSequence sequenceWithObject:[[FOXRoseTree alloc] initWithValue:@2]]]);
        });

        it(@"should not equal to trees with different values and children", ^{
            inputTree1 should_not equal(inputTree2);
            inputTree1 should_not equal([[FOXRoseTree alloc] initWithValue:@1]);
        });

        it(@"should be encodable", ^{
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:inputTree1];
            FOXRoseTree *tree = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            tree should equal(inputTree1);
        });
    });

    describe(@"permutations", ^{
        it(@"should generate permutations by replacing children as given tree, for each tree in the array", ^{
            id<FOXSequence> trees = [FOXRoseTree permutationsOfRoseTrees:@[inputTree1, inputTree2]];
            NSArray *compressedExpectedResult = @[@[@[@2, @[]],
                                                    @[@3, @[@[@4, @[]]]]],
                                                  @[@[@1, @[@[@2, @[]]]],
                                                    @[@4, @[]]]];
            trees should equal([[FOXSequence sequenceFromArray:compressedExpectedResult] sequenceByMapping:^id(NSArray *item) {
                NSMutableArray *subarray = [NSMutableArray array];
                for (id subtree in item) {
                    [subarray addObject:[FOXRoseTree treeFromArray:subtree]];
                }
                return subarray;
            }]);
        });
    });

    describe(@"joining trees", ^{
        it(@"should remove one level of nesting", ^{
#define TREE(...) [FOXRoseTree treeFromArray:(__VA_ARGS__)]
            FOXRoseTree *inputTree = TREE(@[TREE(@[@[@-1, @-3], @[]]),
                                            @[@[TREE(@[@[@-1, @0], @[]]), @[]],
                                              @[TREE(@[@[@-1, @-2], @[]]),
                                                @[@[TREE(@[@[@-1, @0], @[]]), @[]],
                                                  @[TREE(@[@[@-1, @-1], @[]]),
                                                    @[@[TREE(@[@[@-1, @0], @[]]), @[]]]]]]]]);
            FOXRoseTree *joinedTree = [FOXRoseTree joinedTreeFromNestedRoseTree:inputTree];
            joinedTree should equal(TREE(@[@[@-1, @-3],
                                           @[@[@[@-1, @0], @[]],
                                             @[@[@-1, @-2],
                                               @[@[@[@-1, @0], @[]],
                                                 @[@[@-1, @-1], @[@[@[@-1, @0], @[]]]]]]]]
                                         ));
#undef TREE
        });
    });

    describe(@"zipping rose trees", ^{
        it(@"should combine trees without reducing their size", ^{
            FOXRoseTree *tree = [FOXRoseTree zipTreeFromRoseTrees:@[inputTree1, inputTree2]];
            tree should equal([FOXRoseTree treeFromArray:@[@[@1, @3], @[@[@[@2, @3], @[@[@[@2, @4], @[]]]], @[@[@1, @4], @[@[@[@2, @4], @[]]]]]]]);
        });
    });

    describe(@"shrinking rose trees", ^{
        context(@"when there are no trees", ^{
            it(@"should return an rose tree with an empty array", ^{
                FOXRoseTree *tree = [FOXRoseTree shrinkTreeFromRoseTrees:@[]];
                tree should equal([[FOXRoseTree alloc] initWithValue:@[]]);
            });
        });

        it(@"should return all permutations of the same size + permutations with one less element", ^{
            FOXRoseTree *tree = [FOXRoseTree shrinkTreeFromRoseTrees:@[inputTree1, inputTree2]];
            tree should equal([FOXRoseTree treeFromArray:@[@[@1, @3],
                @[@[@[@3],
                    @[@[@[], @[]], @[@[@4], @[@[@[], @[]]]]]],
                    @[@[@1],
                        @[@[@[], @[]], @[@[@2], @[@[@[], @[]]]]]],
                    @[@[@2, @3],
                        @[@[@[@3], @[@[@[], @[]], @[@[@4], @[@[@[], @[]]]]]],
                            @[@[@2], @[@[@[], @[]]]],
                            @[@[@2, @4], @[@[@[@4], @[@[@[], @[]]]], @[@[@2], @[@[@[], @[]]]]]]]],
                    @[@[@1, @4],
                        @[@[@[@4], @[@[@[], @[]]]],
                            @[@[@1], @[@[@[], @[]], @[@[@2], @[@[@[], @[]]]]]],
                            @[@[@2, @4], @[@[@[@4], @[@[@[], @[]]]], @[@[@2], @[@[@[], @[]]]]]]]]]]]);
        });
    });
});

SPEC_END

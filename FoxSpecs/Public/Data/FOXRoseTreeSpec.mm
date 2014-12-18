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

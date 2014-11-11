#import <Cedar/Cedar.h>
#import "PBTRoseTree.h"
#import "PBTSequence.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTRoseTreeSpec)

describe(@"PBTRoseTree", ^{
    __block PBTRoseTree *inputTree1;
    __block PBTRoseTree *inputTree2;

    beforeEach(^{
        inputTree1 = [[PBTRoseTree alloc] initWithValue:@1 children:[PBTSequence sequenceWithObject:[[PBTRoseTree alloc] initWithValue:@2]]];
        inputTree2 = [[PBTRoseTree alloc] initWithValue:@3 children:[PBTSequence sequenceWithObject:[[PBTRoseTree alloc] initWithValue:@4]]];
    });

    describe(@"permutations", ^{
        it(@"should generate permutations by replacing children as given tree, for each tree in the array", ^{
            PBTRoseTree *tree = [PBTRoseTree permutationsOfRoseTrees:@[inputTree1, inputTree2]];
            NSArray *compressedExpectedResult = @[@[@[@2, @[]],
                                                    @[@3, @[@[@4, @[]]]]],
                                                  @[@[@1, @[@[@2, @[]]]],
                                                    @[@4, @[]]]];
            tree should equal([[PBTSequence sequenceFromArray:compressedExpectedResult] sequenceByApplyingBlock:^id(NSArray *item) {
                NSMutableArray *subarray = [NSMutableArray array];
                for (id subtree in item) {
                    [subarray addObject:[PBTRoseTree treeFromArray:subtree]];
                }
                return subarray;
            }]);
        });
    });

    describe(@"zipping rose trees", ^{
        it(@"should combine trees without reducing their size", ^{
            PBTRoseTree *tree = [PBTRoseTree zipTreeFromRoseTrees:@[inputTree1, inputTree2]];
            tree should equal([PBTRoseTree treeFromArray:@[@[@1, @3], @[@[@[@2, @3], @[@[@[@2, @4], @[]]]], @[@[@1, @4], @[@[@[@2, @4], @[]]]]]]]);
        });
    });

    describe(@"shrinking rose trees", ^{
        context(@"when there are no trees", ^{
            it(@"should return an rose tree with an empty array", ^{
                PBTRoseTree *tree = [PBTRoseTree shrinkTreeFromRoseTrees:@[]];
                tree should equal([[PBTRoseTree alloc] initWithValue:@[]]);
            });
        });

        it(@"should return all permutations of the same size + permutations with one less element", ^{
            PBTRoseTree *tree = [PBTRoseTree shrinkTreeFromRoseTrees:@[inputTree1, inputTree2]];
            tree should equal([PBTRoseTree treeFromArray:@[@[@1, @3],
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

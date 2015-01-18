#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXBindSpec)

describe(@"FOXBind", ^{
    describe(@"Example Test", ^{
        FOXRoseTree *threeShrinkTree = [FOXRoseTree treeFromArray:@[@3, @[@[@0, @[]],
                                                                          @[@2, @[@[@0, @[]],
                                                                                  @[@1, @[@[@0, @[]]]]]]]]];


        it(@"should not change the original binded tree", ^{
            id<FOXGenerator> generator = FOXBind(FOXGenPure(threeShrinkTree), ^id<FOXGenerator>(id generatedValue) {
                return FOXReturn(generatedValue);
            });

            id<FOXRandom> random = [[FOXConstantRandom alloc] initWithValue:0];
            FOXRoseTree *tree = [generator lazyTreeWithRandom:random maximumSize:5];
            tree should equal(threeShrinkTree);
        });
    });

    it(@"should no-op if the binding block only returns", ^{
        id<FOXGenerator> originalGenerator = FOXResize(FOXChoose(@0, @3), 5);
        id<FOXGenerator> bindedGenerator = FOXBind(originalGenerator, ^id<FOXGenerator>(id generatedValue) {
            return FOXReturn(generatedValue);
        });
        id<FOXRandom> random = [[FOXConstantRandom alloc] initWithValue:2];
        FOXRoseTree *tree = [bindedGenerator lazyTreeWithRandom:random maximumSize:50];
        FOXRoseTree *expectedTree = [originalGenerator lazyTreeWithRandom:random maximumSize:50];
        tree should equal(expectedTree);
    });

    it(@"should shrink both values, but may not be fully minimal", ^{
        id<FOXGenerator> generator = FOXBind(FOXInteger(), ^id<FOXGenerator>(id value1) {
            return FOXBind(FOXInteger(), ^id<FOXGenerator>(id value2) {
                return FOXReturn(@[value1, value2]);
            });
        });
        id<FOXGenerator> property = FOXForAll(generator, ^BOOL(id values) {
            return [values[0] integerValue] + [values[1] integerValue] < 10;
        });
        FOXRunnerResult *result = [FOXSpecHelper resultForProperty:property];
        result.succeeded should be_falsy;
        NSArray *tuple = result.smallestFailingValue;
        NSInteger sum = [tuple[0] integerValue] + [tuple[1] integerValue];
        sum should be_greater_than_or_equal_to(10);
    });
});

SPEC_END

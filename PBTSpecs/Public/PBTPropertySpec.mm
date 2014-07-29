#import "PBT.h"
#import "PBTQuickCheck.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTPropertySpec)

describe(@"PBTProperty", ^{
    __block id<PBTGenerator> property;
    __block id<PBTRandom> random;

    it(@"should generate passed results", ^{
        random = [[PBTConstantRandom alloc] initWithDoubleValue:2];
        property = [PBTProperty forAll:PBTReturn(@1) then:^PBTPropertyStatus(id value){
            return PBTRequire([@1 isEqual:value]);
        }];
        PBTRoseTree *tree = [property lazyTreeWithRandom:random maximumSize:1];

        PBTPropertyResult *result = tree.value;
        result.status should equal(PBTPropertyStatusPassed);
        result.generatedValue should equal(@1);

        tree.children should be_nil;
    });

    it(@"should generate failed results", ^{
        random = [[PBTConstantRandom alloc] initWithDoubleValue:2];
        property = [PBTProperty forAll:PBTReturn(@2) then:^PBTPropertyStatus(id value){
            return PBTRequire([@1 isEqual:value]);
        }];
        PBTRoseTree *tree = [property lazyTreeWithRandom:random maximumSize:1];

        PBTPropertyResult *result = tree.value;
        result.status should equal(PBTPropertyStatusFailed);
        result.generatedValue should equal(@2);

        tree.children should be_nil;
    });

    it(@"should be shrinkable", ^{
        PBTQuickCheck *quick = [[PBTQuickCheck alloc] init];
        PBTQuickCheckResult *result = [quick checkWithNumberOfTests:100 forAll:PBTInteger() then:^PBTPropertyStatus(NSNumber *generatedValue) {
            return PBTRequire([generatedValue integerValue] / 2 <= [generatedValue integerValue]);
        }];
        result.succeeded should be_falsy;
        result.failingArguments should be_less_than(@0);
        result.smallestFailingArguments should equal(@(-1));
        result.smallestFailingArguments should be_greater_than_or_equal_to(result.failingArguments);
    });

    fit(@"should validate arbitary data structures", ^{
        random = [[PBTConstantRandom alloc] initWithDoubleValue:2];
        property = [PBTProperty forAll:PBTArray(PBTInteger()) then:^PBTPropertyStatus(NSArray *value){
            return PBTRequire(value.count < 2);
        }];
        PBTQuickCheck *quick = [[PBTQuickCheck alloc] init];
        PBTQuickCheckResult *result = [quick checkWithNumberOfTests:100 property:property];
        NSLog(@"================> RESULT: %@", result);
    });
});

SPEC_END

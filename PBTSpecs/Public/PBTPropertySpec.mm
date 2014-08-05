#import "PBT.h"
#import "PBTQuickCheck.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTPropertySpec)

describe(@"PBTProperty", ^{
    __block id<PBTGenerator> property;
    __block id<PBTRandom> random;

    it(@"should generate passed results", ^{
        random = [[PBTConstantRandom alloc] initWithValue:2];
        property = [PBTProperty forAll:PBTReturn(@1) then:^PBTPropertyStatus(id value){
            return PBTRequire([@1 isEqual:value]);
        }];
        PBTRoseTree *tree = [property lazyTreeWithRandom:random maximumSize:1];

        PBTPropertyResult *result = tree.value;
        result.status should equal(PBTPropertyStatusPassed);
        result.generatedValue should equal(@1);
    });

    it(@"should generate failed results", ^{
        random = [[PBTConstantRandom alloc] initWithValue:2];
        property = [PBTProperty forAll:PBTReturn(@2) then:^PBTPropertyStatus(id value){
            return PBTRequire([@1 isEqual:value]);
        }];
        PBTRoseTree *tree = [property lazyTreeWithRandom:random maximumSize:1];

        PBTPropertyResult *result = tree.value;
        result.status should equal(PBTPropertyStatusFailed);
        result.generatedValue should equal(@2);
    });

    it(@"should be shrinkable", ^{
        PBTQuickCheck *quick = [[PBTQuickCheck alloc] initWithReporter:nil];
        PBTQuickCheckResult *result = [quick checkWithNumberOfTests:100 forAll:PBTInteger() then:^PBTPropertyStatus(NSNumber *generatedValue) {
            return PBTRequire([generatedValue integerValue] / 2 <= [generatedValue integerValue]);
        }];
        result.succeeded should be_falsy;
        result.failingArguments should be_less_than(@0);
        result.smallestFailingArguments should equal(@(-1));
        result.smallestFailingArguments should be_greater_than_or_equal_to(result.failingArguments);
    });

    it(@"should validate arbitary data structures", ^{
        random = [[PBTConstantRandom alloc] initWithValue:2];
        property = [PBTProperty forAll:PBTArray(PBTInteger()) then:^PBTPropertyStatus(NSArray *value){
            return PBTRequire(value.count < 2);
        }];
        PBTQuickCheck *quick = [[PBTQuickCheck alloc] initWithReporter:nil];
        PBTQuickCheckResult *result = [quick checkWithNumberOfTests:100 property:property];
        result.smallestFailingArguments should equal(@[@0, @0]);
    });

    it(@"should capture and report exceptions", ^{
        NSException *exception = [NSException exceptionWithName:@"hand" reason:@"answer" userInfo:nil];
        random = [[PBTConstantRandom alloc] initWithValue:2];
        property = [PBTProperty forAll:PBTArray(PBTInteger()) then:^PBTPropertyStatus(NSArray *value){
            [exception raise];
            return PBTRequire(YES);
        }];
        PBTRoseTree *tree = [property lazyTreeWithRandom:random maximumSize:1];
        PBTPropertyResult *propertyResult = tree.value;
        propertyResult.status should equal(PBTPropertyStatusUncaughtException);
        propertyResult.uncaughtException should be_same_instance_as(exception);

        PBTQuickCheck *quick = [[PBTQuickCheck alloc] initWithReporter:nil];
        PBTQuickCheckResult *qcResult = [quick checkWithNumberOfTests:100 property:property];
        qcResult.failingException should be_same_instance_as(exception);
        qcResult.smallestFailingException should be_same_instance_as(exception);
    });
});

SPEC_END

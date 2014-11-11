#import <Cedar/Cedar.h>
#import "PBT.h"
#import "PBTRunner.h"
#import "PBTArrayGenerators.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTPropertySpec)

describe(@"PBTProperty", ^{
    __block id<PBTGenerator> property;
    __block id<PBTRandom> random;

    it(@"should generate passed results", ^{
        random = [[PBTConstantRandom alloc] initWithValue:2];
        property = PBTForAll(PBTReturn(@1), ^PBTPropertyStatus(id value) {
            return PBTRequire([@1 isEqual:value]);
        });
        PBTRoseTree *tree = [property lazyTreeWithRandom:random maximumSize:1];

        PBTPropertyResult *result = tree.value;
        result.status should equal(PBTPropertyStatusPassed);
        result.generatedValue should equal(@1);
    });

    it(@"should generate failed results", ^{
        random = [[PBTConstantRandom alloc] initWithValue:2];
        property = PBTForAll(PBTReturn(@2), ^PBTPropertyStatus(id value) {
            return PBTRequire([@1 isEqual:value]);
        });
        PBTRoseTree *tree = [property lazyTreeWithRandom:random maximumSize:1];

        PBTPropertyResult *result = tree.value;
        result.status should equal(PBTPropertyStatusFailed);
        result.generatedValue should equal(@2);
    });

    it(@"should be shrinkable", ^{
        PBTRunner *quick = [[PBTRunner alloc] initWithReporter:nil];
        PBTRunnerResult *result = [quick resultForNumberOfTests:100 forAll:PBTInteger() then:^PBTPropertyStatus(NSNumber *generatedValue) {
            return PBTRequire([generatedValue integerValue] / 2 <= [generatedValue integerValue]);
        }];
        result.succeeded should be_falsy;
        result.failingValue should be_less_than(@0);
        result.smallestFailingValue should equal(@(-1));
        result.smallestFailingValue should be_greater_than_or_equal_to(result.failingValue);
    });

    it(@"should validate arbitary data structures", ^{
        random = [[PBTConstantRandom alloc] initWithValue:2];
        property = PBTForAll(PBTArray(PBTInteger()), ^PBTPropertyStatus(NSArray *value) {
            return PBTRequire(value.count < 2);
        });
        PBTRunner *quick = [[PBTRunner alloc] initWithReporter:nil];
        PBTRunnerResult *result = [quick resultForNumberOfTests:100 property:property];
        result.smallestFailingValue should equal(@[@0, @0]);
    });

    it(@"should capture and report exceptions", ^{
        NSException *exception = [NSException exceptionWithName:@"hand" reason:@"answer" userInfo:nil];
        random = [[PBTConstantRandom alloc] initWithValue:2];
        property = PBTForAll(PBTArray(PBTInteger()), ^PBTPropertyStatus(NSArray *value) {
            [exception raise];
            return PBTRequire(YES);
        });
        PBTRoseTree *tree = [property lazyTreeWithRandom:random maximumSize:1];
        PBTPropertyResult *propertyResult = tree.value;
        propertyResult.status should equal(PBTPropertyStatusUncaughtException);
        propertyResult.uncaughtException should be_same_instance_as(exception);

        PBTRunner *quick = [[PBTRunner alloc] initWithReporter:nil];
        PBTRunnerResult *qcResult = [quick resultForNumberOfTests:100 property:property];
        qcResult.failingException should be_same_instance_as(exception);
        qcResult.smallestFailingException should be_same_instance_as(exception);
    });
});

SPEC_END

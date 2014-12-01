#import <Cedar.h>
#import "FOX.h"
#import "FOXRunner.h"
#import "FOXArrayGenerators.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXPropertySpec)

describe(@"FOXProperty", ^{
    __block id<FOXGenerator> property;
    __block id<FOXRandom> random;

    it(@"should generate passed results", ^{
        random = [[FOXConstantRandom alloc] initWithValue:2];
        property = FOXForSome(FOXReturn(@1), ^FOXPropertyStatus(id value) {
            return FOXRequire([@1 isEqual:value]);
        });
        FOXRoseTree *tree = [property lazyTreeWithRandom:random maximumSize:1];

        FOXPropertyResult *result = tree.value;
        result.status should equal(FOXPropertyStatusPassed);
        result.generatedValue should equal(@1);
    });

    it(@"should generate failed results", ^{
        random = [[FOXConstantRandom alloc] initWithValue:2];
        property = FOXForSome(FOXReturn(@2), ^FOXPropertyStatus(id value) {
            return FOXRequire([@1 isEqual:value]);
        });
        FOXRoseTree *tree = [property lazyTreeWithRandom:random maximumSize:1];

        FOXPropertyResult *result = tree.value;
        result.status should equal(FOXPropertyStatusFailed);
        result.generatedValue should equal(@2);
    });

    it(@"should be shrinkable", ^{
        FOXRunner *quick = [[FOXRunner alloc] initWithReporter:nil];
        FOXRunnerResult *result = [quick resultForNumberOfTests:100
                                                        forSome:FOXInteger()
                                                           then:^FOXPropertyStatus(NSNumber *generatedValue) {
                                                               return FOXRequire([generatedValue integerValue] / 2 <= [generatedValue integerValue]);
                                                           }];
        result.succeeded should be_falsy;
        result.failingValue should be_less_than(@0);
        result.smallestFailingValue should equal(@(-1));
        result.smallestFailingValue should be_greater_than_or_equal_to(result.failingValue);
    });

    it(@"should validate arbitary data structures", ^{
        random = [[FOXConstantRandom alloc] initWithValue:2];
        property = FOXForSome(FOXArray(FOXInteger()), ^FOXPropertyStatus(NSArray *value) {
            return FOXRequire(value.count < 2);
        });
        FOXRunner *quick = [[FOXRunner alloc] initWithReporter:nil];
        FOXRunnerResult *result = [quick resultForNumberOfTests:100 property:property];
        result.smallestFailingValue should equal(@[@0, @0]);
    });

    it(@"should capture and report exceptions", ^{
        NSException *exception = [NSException exceptionWithName:@"hand" reason:@"answer" userInfo:nil];
        random = [[FOXConstantRandom alloc] initWithValue:2];
        property = FOXForSome(FOXArray(FOXInteger()), ^FOXPropertyStatus(NSArray *value) {
            [exception raise];
            return FOXRequire(YES);
        });
        FOXRoseTree *tree = [property lazyTreeWithRandom:random maximumSize:1];
        FOXPropertyResult *propertyResult = tree.value;
        propertyResult.status should equal(FOXPropertyStatusUncaughtException);
        propertyResult.uncaughtException should be_same_instance_as(exception);

        FOXRunner *quick = [[FOXRunner alloc] initWithReporter:nil];
        FOXRunnerResult *qcResult = [quick resultForNumberOfTests:100 property:property];
        qcResult.failingException should be_same_instance_as(exception);
        qcResult.smallestFailingException should be_same_instance_as(exception);
    });
});

describe(@"FOXForAll", ^{
    it(@"should validate all permutations of the data", ^{
        FOXAssert(FOXForAll(FOXInteger(), ^BOOL(id generatedValue) {
            return YES;
        }));
    });
});

describe(@"FOXForSome", ^{
    it(@"should allow skipping of tests", ^{
        id<FOXReporter> reporter = nice_fake_for(@protocol(FOXReporter));
        FOXRunner *runner = [[FOXRunner alloc] initWithReporter:reporter];
        id<FOXGenerator> property = FOXForSome(FOXInteger(), ^FOXPropertyStatus(id generatedValue) {
            return FOXPropertyStatusSkipped;
        });
        FOXRunnerResult *result = [runner resultForNumberOfTests:100 property:property];

        result.succeeded should be_truthy;
        reporter should have_received(@selector(runnerWillRunWithSeed:));
        reporter should have_received(@selector(runnerWillVerifyTestNumber:withMaximumSize:));
        reporter should have_received(@selector(runnerDidSkipTestNumber:propertyResult:));
        reporter should_not have_received(@selector(runnerDidPassTestNumber:propertyResult:));
        reporter should have_received(@selector(runnerDidPassNumberOfTests:withResult:));
        reporter should have_received(@selector(runnerDidRunWithResult:));
    });
});

SPEC_END

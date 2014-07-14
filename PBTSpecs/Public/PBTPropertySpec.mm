#import "PBT.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTPropertySpec)

describe(@"PBTProperty", ^{
    __block PBTGenerator propertyGenerator;
    __block id<PBTRandom> random;

    it(@"should generate passed results", ^{
        random = [[PBTConstantRandom alloc] initWithDoubleValue:2];
        propertyGenerator = [PBTProperty forAll:PBTReturn(@1) then:^PBTPropertyStatus(id value){
            return PBTRequire([@1 isEqual:value]);
        }];
        PBTRoseTree *tree = propertyGenerator(random, @1);

        PBTPropertyResult *result = tree.value;
        result.status should equal(@(PBTPropertyStatusPassed));
        result.generatedValue should equal(@1);

        tree.children should be_nil;
    });

    it(@"should generate failed results", ^{
        random = [[PBTConstantRandom alloc] initWithDoubleValue:2];
        propertyGenerator = [PBTProperty forAll:PBTReturn(@2) then:^PBTPropertyStatus(id value){
            return PBTRequire([@1 isEqual:value]);
        }];
        PBTRoseTree *tree = propertyGenerator(random, @1);

        PBTPropertyResult *result = tree.value;
        result.status should equal(@(PBTPropertyStatusFailed));
        result.generatedValue should equal(@2);

        tree.children should be_nil;
    });

    it(@"should shrink to failed results", ^{
        random = [[PBTConstantRandom alloc] initWithDoubleValue:10];
        propertyGenerator = [PBTProperty forAll:PBTInt() then:^PBTPropertyStatus(id value){
            return PBTRequire([value integerValue] >= 10);
        }];
        PBTRoseTree *tree = propertyGenerator(random, @10);

        NSLog(@"================> %@", tree);

        PBTPropertyResult *result = tree.value;
        result.status should equal(@(PBTPropertyStatusFailed));
        result.generatedValue should equal(@0);
    });
});

SPEC_END

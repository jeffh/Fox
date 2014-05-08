#import "PBTProperty.h"
#import "PBTRandom.h"
#import "PBTConstantRandom.h"
#import "PBTSequence.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTPropertySpec)

describe(@"PBTProperty", ^{
    __block PBTGenerator propertyGenerator;
    __block id<PBTRandom> random;

    beforeEach(^{
        random = [[PBTConstantRandom alloc] initWithDoubleValue:2];
        propertyGenerator = [PBTProperty forAll:PBTReturn(@1) then:^PBTPropertyResult(id value){
            return PBTRequire([value isEqual:@1]);
        }];
    });

    it(@"should generate passing values", ^{
        id<PBTSequence> seq = propertyGenerator(random, 1);
        [seq firstObject] should equal(@(PBTPropertyResultPassed));
        [[seq remainingSequence] firstObject] should equal(@(PBTPropertyResultPassed));
    });
});

SPEC_END

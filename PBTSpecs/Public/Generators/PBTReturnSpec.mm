#import "PBT.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTReturnSpec)

describe(@"PBTReturn", ^{
    it(@"should always return the given value", ^{
        for (NSUInteger i = 0; i < 10; i++) {
            PBTConstantRandom *random = [[PBTConstantRandom alloc] initWithDoubleValue:i];
            id<PBTSequence> tree = PBTReturn(@1)(random, i);
            [[tree firstObject] firstObject] should equal(@1);
            [[tree firstObject] remainingSequence] should be_nil;
            [tree remainingSequence] should be_nil;
        }
    });
});

SPEC_END

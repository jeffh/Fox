#import "PBT.h"
#import "PBTSpecHelper.h"
#include "PBTArrayGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTTupleGeneratorSpec)

describe(@"PBTTuple", ^{
    it(@"should always have the same size", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTTuple(@[PBTInteger(), PBTInteger()]) then:^BOOL(NSArray *values) {
            return [values count] == 2;
        }];
        result.succeeded should be_truthy;
    });

    it(@"should foo", ^{
        PBTRoseTree *tree = [PBTRoseTree zipTreeFromRoseTrees:@[[[PBTRoseTree alloc] initWithValue:@1],
                                                                [[PBTRoseTree alloc] initWithValue:@2]]];
        tree should equal([[PBTRoseTree alloc] initWithValue:@[@1, @2]]);
    });

    it(@"should always have the same size when shrunk", ^{
        PBTRunnerResult *result = [PBTSpecHelper shrunkResultForAll:PBTTuple(@[PBTInteger(), PBTInteger()])];
        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@[@0, @0]);
    });
});

SPEC_END

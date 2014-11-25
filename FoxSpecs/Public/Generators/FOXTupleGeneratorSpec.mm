#import <Cedar/Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"
#import "FOXArrayGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXTupleGeneratorSpec)

describe(@"FOXTuple", ^{
    it(@"should always have the same size", ^{
        FOXAssert(FOXForAll(FOXTuple(@[FOXInteger(), FOXInteger()]), ^BOOL(NSArray *values) {
            return [values count] == 2;
        }));
    });

    it(@"should foo", ^{
        FOXRoseTree *tree = [FOXRoseTree zipTreeFromRoseTrees:@[[[FOXRoseTree alloc] initWithValue:@1],
            [[FOXRoseTree alloc] initWithValue:@2]]];
        tree should equal([[FOXRoseTree alloc] initWithValue:@[@1, @2]]);
    });

    it(@"should always have the same size when shrunk", ^{
        FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXTuple(@[FOXInteger(), FOXInteger()])];
        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@[@0, @0]);
    });
});

SPEC_END

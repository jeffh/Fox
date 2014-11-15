#import <Cedar/Cedar.h>
#import "PBT.h"
#import "PBTSpecHelper.h"
#import "PBTStringGenerators.h"
#import "PBTDictionaryGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTDictionarySpec)

describe(@"PBTDictionary", ^{
    it(@"should always return the same size as the template", ^{
        PBTAssert(PBTForAll(PBTDictionary(@{@"a" : PBTString(), @"b" : PBTInteger()}), ^BOOL(NSDictionary *value) {
            return [value count] == 2;
        }));
    });

    it(@"should be able to return dictionary where values are generated", ^{
        PBTAssert(PBTForAll(PBTDictionary(@{@"a": PBTString(), @"b": PBTInteger()}), ^BOOL(id value) {
            return [value[@"a"] isKindOfClass:[NSString class]]
                && [value[@"b"] isKindOfClass:[NSNumber class]];
        }));
    });

    it(@"should shrink its values down", ^{
        PBTRunnerResult *result = [PBTSpecHelper shrunkResultForAll:PBTDictionary(@{@"a": PBTString(), @"b": PBTInteger()})];
        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@{@"a": @"", @"b": @0});
    });
});

SPEC_END

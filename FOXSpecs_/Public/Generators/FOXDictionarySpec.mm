#import <Cedar/Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"
#import "FOXStringGenerators.h"
#import "FOXDictionaryGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXDictionarySpec)

describe(@"FOXDictionary", ^{
    it(@"should always return the same size as the template", ^{
        FOXAssert(FOXForAll(FOXDictionary(@{@"a" : FOXString(), @"b" : FOXInteger()}), ^BOOL(NSDictionary *value) {
            return [value count] == 2;
        }));
    });

    it(@"should be able to return dictionary where values are generated", ^{
        FOXAssert(FOXForAll(FOXDictionary(@{@"a" : FOXString(), @"b" : FOXInteger()}), ^BOOL(id value) {
            return [value[@"a"] isKindOfClass:[NSString class]]
                && [value[@"b"] isKindOfClass:[NSNumber class]];
        }));
    });

    it(@"should shrink its values down", ^{
        FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXDictionary(@{@"a" : FOXString(), @"b" : FOXInteger()})];
        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@{@"a": @"", @"b": @0});
    });
});

SPEC_END

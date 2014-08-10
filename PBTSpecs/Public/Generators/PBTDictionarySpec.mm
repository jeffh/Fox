#import "PBT.h"
#import "PBTSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTDictionarySpec)

describe(@"PBTDictionary", ^{
    it(@"should always return the same size as the template", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTDictionary(@{@"a": PBTString(), @"b": PBTInteger()}) then:^BOOL(NSDictionary *value) {
            return [value count] == 2;
        }];
        result.succeeded should be_truthy;
    });

    it(@"should be able to return dictionary where values are generated", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTDictionary(@{@"a": PBTString(), @"b": PBTInteger()}) then:^BOOL(id value) {
            return [value[@"a"] isKindOfClass:[NSString class]]
                && [value[@"b"] isKindOfClass:[NSNumber class]];
        }];
        result.succeeded should be_truthy;
    });

    it(@"should shrink its values down", ^{
        PBTRunnerResult *result = [PBTSpecHelper shrunkResultForAll:PBTDictionary(@{@"a": PBTString(), @"b": PBTInteger()})];
        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@{@"a": @"", @"b": @0});
    });
});

SPEC_END

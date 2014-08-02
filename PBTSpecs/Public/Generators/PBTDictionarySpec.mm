#import "PBT.h"
#import "PBTSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTDictionarySpec)

xdescribe(@"PBTDictionary", ^{
    it(@"should be able to return dictionary of any size", ^{
        PBTQuickCheckResult *result = [PBTSpecHelper resultForAll:PBTSet(PBTInteger()) then:^BOOL(id value) {
            BOOL isValid = YES;
            for (id element in value) {
                if (![element isKindOfClass:[NSNumber class]]) {
                    isValid = NO;
                }
            }
            return isValid;
        }];
        result.succeeded should be_truthy;
    });

    it(@"should be able to return dictionary of a given size", ^{
        PBTQuickCheckResult *result = [PBTSpecHelper resultForAll:PBTArray(PBTInteger(), 5) then:^BOOL(id value) {
            return [value count] == 5;
        }];
        result.succeeded should be_truthy;
    });

    it(@"should be able to return dictionary of a given size range", ^{
        PBTQuickCheckResult *result = [PBTSpecHelper resultForAll:PBTArray(PBTInteger(), 5, 10) then:^BOOL(id value) {
            NSUInteger count = [value count];
            return count >= 5 && count <= 10;
        }];
        result.succeeded should be_truthy;
    });});

SPEC_END

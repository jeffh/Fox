#import "PBT.h"
#import "PBTSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PBTArraySpec)

describe(@"PBTArray", ^{
    it(@"should be able to return arrays of any size", ^{
        NSMutableSet *sizesSeen = [NSMutableSet set];
        PBTQuickCheckResult *result = [PBTSpecHelper resultForAll:PBTArray(PBTInteger()) then:^BOOL(id value) {
            BOOL isValid = YES;
            for (id element in value) {
                if (![element isKindOfClass:[NSNumber class]]) {
                    isValid = NO;
                }
            }
            [sizesSeen addObject:@([value count])];
            return isValid;
        }];
        result.succeeded should be_truthy;
        sizesSeen.count should be_greater_than(1);
    });

    it(@"should be able to return arrays of a given size", ^{
        PBTQuickCheckResult *result = [PBTSpecHelper resultForAll:PBTArray(PBTInteger(), 5) then:^BOOL(id value) {
            return [value count] == 5;
        }];
        result.succeeded should be_truthy;
    });

    it(@"should be able to return arrays of a given size range", ^{
        PBTQuickCheckResult *result = [PBTSpecHelper debug_resultForAll:PBTArray(PBTInteger(), 5, 10) then:^BOOL(id value) {
            NSUInteger count = [value count];
            return count >= 5 && count < 10;
        }];
        result.succeeded should be_truthy;
    });
});

SPEC_END

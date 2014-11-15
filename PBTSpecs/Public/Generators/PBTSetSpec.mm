#import <Cedar/Cedar.h>
#import "PBT.h"
#import "PBTSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTSetSpec)

describe(@"PBTSet", ^{
    it(@"should be able to return sets of any size", ^{
        NSMutableSet *sizesSeen = [NSMutableSet set];
        PBTAssert(PBTForAll(PBTSet(PBTInteger()), ^BOOL(id value) {
            BOOL isValid = YES;
            for (id element in value) {
                if (![element isKindOfClass:[NSNumber class]]) {
                    isValid = NO;
                }
            }
            [sizesSeen addObject:@([value count])];
            return isValid;
        }));
        sizesSeen.count should be_greater_than(1);
    });
});

SPEC_END

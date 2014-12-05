#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXOptionalSpec)

describe(@"FOXOptional", ^{
    it(@"should occationally produce nil", ^{
        __block BOOL gottenNil = NO;
        [FOXSpecHelper resultForAll:FOXOptional(FOXInteger()) then:^BOOL(id value) {
            gottenNil = gottenNil || value == nil;
            return YES;
        }];

        gottenNil should be_truthy;
    });
});

SPEC_END

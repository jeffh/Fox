#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXAlwaysSpec)

describe(@"FOXAlways", ^{
    it(@"should consistently fail flacky behavior", ^{
        FOXRunner *quick = [[FOXRunner alloc] initWithReporter:nil];

        __block NSUInteger count = 0;
        __block id lastSeenValue = nil;
        id<FOXGenerator> property = FOXForAll(FOXInteger(), ^BOOL(id value) {
            if ([lastSeenValue isEqual:value]) {
                ++count;
            }
            lastSeenValue = value;
            if (count == 10) {
                count = 0;
                return NO;
            }
            return YES;
        });
        FOXRunnerResult *result = [quick resultForNumberOfTests:500 property:FOXAlways(10, property)];
        result.succeeded should be_falsy;
    });
});

SPEC_END

#import <Cedar/Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"
#import "FOXStringGenerators.h"
#import "FOXArrayGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXStringSpec)

describe(@"FOXString", ^{
    it(@"should be able to shrink to empty string", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXString() then:^BOOL(NSString *value) {
            // ensure this is realized as a string, and not an array
            return [[NSString stringWithString:value] length] < 5;
        }];
        result.succeeded should be_falsy;
        unichar *smallestString = (unichar *)alloca(sizeof(unichar) * 5);
        for (int i = 0; i < 5; i++) {
            smallestString[i] = 0;
        }
        result.smallestFailingValue should equal([NSString stringWithCharacters:smallestString length:5]);
    });

    it(@"should be able to return strings of any size", ^{
        FOXAssert(FOXForAll(FOXString(), ^BOOL(NSString *value) {
            return [value isKindOfClass:[NSString class]];
        }));
    });

    it(@"should be able to return strings of a given size", ^{
        FOXAssert(FOXForAll(FOXArrayOfSize(FOXInteger(), 5), ^BOOL(id value) {
            return [value count] == 5;
        }));
    });

    it(@"should be able to return strings of a given size range", ^{
        FOXAssert(FOXForAll(FOXArrayOfSizeRange(FOXInteger(), 5, 10), ^BOOL(id value) {
            NSUInteger count = [value count];
            return count >= 5 && count <= 10;
        }));
    });
});

SPEC_END

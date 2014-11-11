#import <Cedar/Cedar.h>
#import "PBT.h"
#import "PBTSpecHelper.h"
#import "PBTStringGenerators.h"
#import "PBTArrayGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTStringSpec)

describe(@"PBTString", ^{
    it(@"should be able to shrink to empty string", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTString() then:^BOOL(NSString *value) {
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
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTString() then:^BOOL(NSString *value) {
            return [value isKindOfClass:[NSString class]];
        }];
        result.succeeded should be_truthy;
    });

    it(@"should be able to return strings of a given size", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTArray(PBTInteger(), 5) then:^BOOL(id value) {
            return [value count] == 5;
        }];
        result.succeeded should be_truthy;
    });

    it(@"should be able to return strings of a given size range", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTArray(PBTInteger(), 5, 10) then:^BOOL(id value) {
            NSUInteger count = [value count];
            return count >= 5 && count <= 10;
        }];
        result.succeeded should be_truthy;
    });
});

SPEC_END

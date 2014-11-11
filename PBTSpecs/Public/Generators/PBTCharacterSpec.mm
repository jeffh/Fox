#import <Cedar/Cedar.h>
#import "PBT.h"
#import "PBTSpecHelper.h"
#import "PBTStringGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTCharacterSpec)

describe(@"PBTCharacter", ^{
    it(@"should be able shrink characters", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTCharacter() then:^BOOL(NSNumber *character) {
            return [character integerValue] > 100;
        }];
        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@0);
    });

    it(@"should be able to produce any character", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTCharacter() then:^BOOL(NSNumber *character) {
            return [character integerValue] >= 0 && [character integerValue] <= 255;
        }];
        result.succeeded should be_truthy;
    });

    it(@"should be able to produce any alpha characters", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTAlphabetCharacter() then:^BOOL(NSNumber *character) {
            return [[NSCharacterSet letterCharacterSet] characterIsMember:[character charValue]];
        }];
        result.succeeded should be_truthy;
    });

    it(@"should be able to produce any numeric characters", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTNumericCharacter() then:^BOOL(NSNumber *character) {
            return [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[character charValue]];
        }];
        result.succeeded should be_truthy;
    });

    it(@"should be able to produce any alphanumeric characters", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTAlphabetCharacter() then:^BOOL(NSNumber *character) {
            return [[NSCharacterSet alphanumericCharacterSet] characterIsMember:[character charValue]];
        }];
        result.succeeded should be_truthy;
    });

    it(@"should be able to produce any ascii characters", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTAsciiCharacter() then:^BOOL(NSNumber *character) {
            return [[NSCharacterSet characterSetWithRange:NSMakeRange(32, 95)] characterIsMember:[character charValue]];
        }];
        result.succeeded should be_truthy;
    });
});

SPEC_END

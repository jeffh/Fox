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
        PBTAssert(PBTForAll(PBTCharacter(), ^BOOL(NSNumber *character) {
            return [character integerValue] >= 0 && [character integerValue] <= 255;
        }));
    });

    it(@"should be able to produce any alpha characters", ^{
        PBTAssert(PBTForAll(PBTAlphabetCharacter(), ^BOOL(NSNumber *character) {
            return [[NSCharacterSet letterCharacterSet] characterIsMember:[character charValue]];
        }));
    });

    it(@"should be able to produce any numeric characters", ^{
        PBTAssert(PBTForAll(PBTNumericCharacter(), ^BOOL(NSNumber *character) {
            return [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[character charValue]];
        }));
    });

    it(@"should be able to produce any alphanumeric characters", ^{
        PBTAssert(PBTForAll(PBTAlphabetCharacter(), ^BOOL(NSNumber *character) {
            return [[NSCharacterSet alphanumericCharacterSet] characterIsMember:[character charValue]];
        }));
    });

    it(@"should be able to produce any ascii characters", ^{
        PBTAssert(PBTForAll(PBTAsciiCharacter(), ^BOOL(NSNumber *character) {
            return [[NSCharacterSet characterSetWithRange:NSMakeRange(32, 95)] characterIsMember:[character charValue]];
        }));
    });
});

SPEC_END

#import <Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"
#import "FOXStringGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXCharacterSpec)

describe(@"FOXCharacter", ^{
    it(@"should be able shrink characters", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXCharacter() then:^BOOL(NSNumber *character) {
            return [character integerValue] > 100;
        }];
        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@0);
    });

    it(@"should be able to produce any character", ^{
        FOXAssert(FOXForAll(FOXCharacter(), ^BOOL(NSNumber *character) {
            return [character integerValue] >= 0 && [character integerValue] <= 255;
        }));
    });

    it(@"should be able to produce any alpha characters", ^{
        FOXAssert(FOXForAll(FOXAlphabetCharacter(), ^BOOL(NSNumber *character) {
            return [[NSCharacterSet letterCharacterSet] characterIsMember:[character charValue]];
        }));
    });

    it(@"should be able to produce any numeric characters", ^{
        FOXAssert(FOXForAll(FOXNumericCharacter(), ^BOOL(NSNumber *character) {
            return [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[character charValue]];
        }));
    });

    it(@"should be able to produce any alphanumeric characters", ^{
        FOXAssert(FOXForAll(FOXAlphabetCharacter(), ^BOOL(NSNumber *character) {
            return [[NSCharacterSet alphanumericCharacterSet] characterIsMember:[character charValue]];
        }));
    });

    it(@"should be able to produce any ascii characters", ^{
        FOXAssert(FOXForAll(FOXAsciiCharacter(), ^BOOL(NSNumber *character) {
            return [[NSCharacterSet characterSetWithRange:NSMakeRange(32, 95)] characterIsMember:[character charValue]];
        }));
    });
});

SPEC_END

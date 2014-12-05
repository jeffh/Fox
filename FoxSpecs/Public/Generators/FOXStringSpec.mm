#import <Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"
#import "FOXStringGenerators.h"
#import "FOXArrayGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

static BOOL stringContainsOnlyCharactersInSet(NSString *string, NSCharacterSet *characterSet) {
    for (NSUInteger i = 0; i < string.length; i++) {
        if (![characterSet characterIsMember:[string characterAtIndex:i]]) {
            return NO;
        }
    }
    return YES;
}

SPEC_BEGIN(FOXStringSpec)

describe(@"String Generation", ^{
    NSUInteger fixedSize = 5;
    NSUInteger minSize = 5;
    NSUInteger maxSize = 10;

    sharedExamplesFor(@"a string generator with a strict characterset", ^(NSDictionary *scope) {
        __block id<FOXGenerator> variableGenerator;
        __block NSCharacterSet *allowedCharacters;

        beforeEach(^{
            variableGenerator = scope[@"variableGenerator"];
            variableGenerator should_not be_nil;
            allowedCharacters = scope[@"allowedCharacters"];
            allowedCharacters should_not be_nil;
        });

        it(@"should observe every character in the allowed characterset", ^{
            NSMutableCharacterSet *set = [[NSMutableCharacterSet alloc] init];
            FOXAssert(FOXForAll(variableGenerator, ^BOOL(NSString *value) {
                [set addCharactersInString:value];
                return YES;
            }));

            set should equal(allowedCharacters);
        });
    });

    sharedExamplesFor(@"a string generator", ^(NSDictionary *scope) {
        __block id<FOXGenerator> variableGenerator;
        __block id<FOXGenerator> fixedSizeGenerator;
        __block id<FOXGenerator> sizeRangeGenerator;
        __block NSCharacterSet *allowedCharacters;

        beforeEach(^{
            variableGenerator = scope[@"variableGenerator"];
            variableGenerator should_not be_nil;
            fixedSizeGenerator = scope[@"fixedSizeGenerator"];
            fixedSizeGenerator should_not be_nil;
            sizeRangeGenerator = scope[@"sizeRangeGenerator"];
            sizeRangeGenerator should_not be_nil;
            allowedCharacters = scope[@"allowedCharacters"];
            allowedCharacters should_not be_nil;
        });

        it(@"should be able to shrink to an empty string", ^{
            FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:variableGenerator];
            result.succeeded should be_falsy;
            result.smallestFailingValue should equal(@"");
        });

        it(@"should be able to return strings of any size", ^{
            FOXAssert(FOXForAll(variableGenerator, ^BOOL(NSString *value) {
                return [value isKindOfClass:[NSString class]]
                    && stringContainsOnlyCharactersInSet(value, allowedCharacters);
            }));
        });

        it(@"should be able to return strings of a given size", ^{
            FOXAssert(FOXForAll(fixedSizeGenerator, ^BOOL(NSString *value) {
                return [value length] == fixedSize
                    && stringContainsOnlyCharactersInSet(value, allowedCharacters);
            }));
        });

        it(@"should be able to return strings of a given size range", ^{
            FOXAssert(FOXForAll(sizeRangeGenerator, ^BOOL(NSString *value) {
                NSUInteger count = [value length];
                return count >= minSize && count <= maxSize
                    && stringContainsOnlyCharactersInSet(value, allowedCharacters);
            }));
        });
    });

    describe(@"FOXString", ^{
        itShouldBehaveLike(@"a string generator", ^(NSMutableDictionary *scope){
            scope[@"variableGenerator"] = FOXString();
            scope[@"fixedSizeGenerator"] = FOXStringOfLength(fixedSize);
            scope[@"sizeRangeGenerator"] = FOXStringOfLengthRange(minSize, maxSize);
            scope[@"allowedCharacters"] = [[[NSCharacterSet alloc] init] invertedSet];
        });

        it(@"should be able to shrink to length of null strings", ^{
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
    });

    describe(@"FOXAsciiString", ^{
        beforeEach(^{
            NSMutableDictionary *scope = [[CDRSpecHelper specHelper] sharedExampleContext];
            scope[@"variableGenerator"] = FOXAsciiString();
            scope[@"fixedSizeGenerator"] = FOXAsciiStringOfLength(fixedSize);
            scope[@"sizeRangeGenerator"] = FOXAsciiStringOfLengthRange(minSize, maxSize);
            scope[@"allowedCharacters"] = [NSCharacterSet characterSetWithRange:NSMakeRange(32, 95)];
        });

        itShouldBehaveLike(@"a string generator");
        itShouldBehaveLike(@"a string generator with a strict characterset");
    });

    describe(@"FOXAlphanumericString", ^{
        beforeEach(^{
            NSMutableDictionary *scope = [[CDRSpecHelper specHelper] sharedExampleContext];
            scope[@"variableGenerator"] = FOXAlphanumericString();
            scope[@"fixedSizeGenerator"] = FOXAlphanumericStringOfLength(fixedSize);
            scope[@"sizeRangeGenerator"] = FOXAlphanumericStringOfLengthRange(minSize, maxSize);
            scope[@"allowedCharacters"] = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijlkmnopqrstuvwxyz1234567890"];
        });

        itShouldBehaveLike(@"a string generator");
        itShouldBehaveLike(@"a string generator with a strict characterset");
    });

    describe(@"FOXAlphabeticalString", ^{
        beforeEach(^{
            NSMutableDictionary *scope = [[CDRSpecHelper specHelper] sharedExampleContext];
            scope[@"variableGenerator"] = FOXAlphabeticalString();
            scope[@"fixedSizeGenerator"] = FOXAlphabeticalStringOfLength(fixedSize);
            scope[@"sizeRangeGenerator"] = FOXAlphabeticalStringOfLengthRange(minSize, maxSize);
            scope[@"allowedCharacters"] = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijlkmnopqrstuvwxyz"];
        });

        itShouldBehaveLike(@"a string generator");
        itShouldBehaveLike(@"a string generator with a strict characterset");
    });

    describe(@"FOXNumericString", ^{
        beforeEach(^{
            NSMutableDictionary *scope = [[CDRSpecHelper specHelper] sharedExampleContext];
            scope[@"variableGenerator"] = FOXNumericString();
            scope[@"fixedSizeGenerator"] = FOXNumericStringOfLength(fixedSize);
            scope[@"sizeRangeGenerator"] = FOXNumericStringOfLengthRange(minSize, maxSize);
            scope[@"allowedCharacters"] = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
        });

        itShouldBehaveLike(@"a string generator");
        itShouldBehaveLike(@"a string generator with a strict characterset");
    });
});

SPEC_END

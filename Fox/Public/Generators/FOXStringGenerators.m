#import "FOXStringGenerators.h"
#import "FOXCoreGenerators.h"
#import "FOXGenerator.h"
#import "FOXStringGenerator.h"
#import "FOXArrayGenerators.h"

FOX_EXPORT id<FOXGenerator> FOXCharacter(void) {
    return FOXWithName(@"Character", FOXChoose(@0, @255));
}

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalCharacter(void) {
    return FOXWithName(@"AlphabeticalCharacter", FOXOneOf(@[FOXChoose(@65, @90),
                                                            FOXChoose(@97, @122)]));
}

FOX_EXPORT id<FOXGenerator> FOXNumericCharacter(void) {
    return FOXWithName(@"NumbericCharacter", FOXChoose(@48, @57));
}

FOX_EXPORT id<FOXGenerator> FOXAlphanumericCharacter(void) {
    return FOXWithName(@"AlphanumericCharacter", FOXOneOf(@[FOXChoose(@48, @57),
                                                            FOXChoose(@65, @90),
                                                            FOXChoose(@97, @122)]));
}

FOX_EXPORT id<FOXGenerator> FOXAsciiCharacter(void) {
    return FOXWithName(@"AsciiCharacter", FOXChoose(@32, @126));
}

FOUNDATION_STATIC_INLINE id<FOXGenerator> createStringGenerator(NSString *name, id<FOXGenerator> arrayGenerator) {
    return [[FOXStringGenerator alloc] initWithArrayOfIntegersGenerator:arrayGenerator name:name];
}

FOX_EXPORT id<FOXGenerator> FOXString(void) {
    return createStringGenerator(@"String", FOXArray(FOXCharacter()));
}

FOX_EXPORT id<FOXGenerator> FOXStringOfLength(NSUInteger length) {
    return createStringGenerator(@"StringOfLength", FOXArrayOfSize(FOXCharacter(), length));
}

FOX_EXPORT id<FOXGenerator> FOXStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength) {
    return createStringGenerator(@"StringOfLengthRange", FOXArrayOfSizeRange(FOXCharacter(), minimumLength, maximumLength));
}

FOX_EXPORT id<FOXGenerator> FOXAsciiString(void) {
    return createStringGenerator(@"AsciiString", FOXArray(FOXAsciiCharacter()));
}

FOX_EXPORT id<FOXGenerator> FOXAsciiStringOfLength(NSUInteger length) {
    return createStringGenerator(@"AsciiStringOfLength", FOXArrayOfSize(FOXAsciiCharacter(), length));
}

FOX_EXPORT id<FOXGenerator> FOXAsciiStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength) {
    return createStringGenerator(@"AsciiStringOfLengthRange", FOXArrayOfSizeRange(FOXAsciiCharacter(), minimumLength, maximumLength));
}

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalString(void) {
    return createStringGenerator(@"AlphabeticalString", FOXArray(FOXAlphabeticalCharacter()));
}

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalStringOfLength(NSUInteger length) {
    return createStringGenerator(@"AlphabeticalStringOfLength", FOXArrayOfSize(FOXAlphabeticalCharacter(), length));
}

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength) {
    return createStringGenerator(@"AlphabeticalStringOfLengthRange", FOXArrayOfSizeRange(FOXAlphabeticalCharacter(), minimumLength, maximumLength));
}

FOX_EXPORT id<FOXGenerator> FOXNumericString(void) {
    return createStringGenerator(@"NumericString", FOXArray(FOXNumericCharacter()));
}

FOX_EXPORT id<FOXGenerator> FOXNumericStringOfLength(NSUInteger length) {
    return createStringGenerator(@"NumericStringOfLength", FOXArrayOfSize(FOXNumericCharacter(), length));
}

FOX_EXPORT id<FOXGenerator> FOXNumericStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength) {
    return createStringGenerator(@"NumericStringOfLengthRange", FOXArrayOfSizeRange(FOXNumericCharacter(), minimumLength, maximumLength));
}

FOX_EXPORT id<FOXGenerator> FOXAlphanumericString(void) {
    return createStringGenerator(@"AlphanumericalString", FOXArray(FOXAlphanumericCharacter()));
}

FOX_EXPORT id<FOXGenerator> FOXAlphanumericStringOfLength(NSUInteger length) {
    return createStringGenerator(@"AlphanumericalStringOfLength", FOXArrayOfSize(FOXAlphanumericCharacter(), length));
}

FOX_EXPORT id<FOXGenerator> FOXAlphanumericStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength) {
    return createStringGenerator(@"AlphanumericalStringOfLengthRange", FOXArrayOfSizeRange(FOXAlphanumericCharacter(), minimumLength, maximumLength));
}

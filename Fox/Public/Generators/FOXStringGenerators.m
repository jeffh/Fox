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
    return createStringGenerator(@"Any", FOXArray(FOXCharacter()));
}

FOX_EXPORT id<FOXGenerator> FOXStringOfSize(NSUInteger size) {
    return createStringGenerator(@"AnyOfSize", FOXArrayOfSize(FOXCharacter(), size));
}

FOX_EXPORT id<FOXGenerator> FOXStringOfSizeRange(NSUInteger minimumSize, NSUInteger maximumSize) {
    return createStringGenerator(@"AnyOfSizeRange", FOXArrayOfSizeRange(FOXCharacter(), minimumSize, maximumSize));
}

FOX_EXPORT id<FOXGenerator> FOXAsciiString(void) {
    return createStringGenerator(@"Ascii", FOXArray(FOXAsciiCharacter()));
}

FOX_EXPORT id<FOXGenerator> FOXAsciiStringOfSize(NSUInteger size) {
    return createStringGenerator(@"AsciiOfSize", FOXArrayOfSize(FOXAsciiCharacter(), size));
}

FOX_EXPORT id<FOXGenerator> FOXAsciiStringOfSizeRange(NSUInteger minimumSize, NSUInteger maximumSize) {
    return createStringGenerator(@"AsciiOfSizeRange", FOXArrayOfSizeRange(FOXAsciiCharacter(), minimumSize, maximumSize));
}

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalString(void) {
    return createStringGenerator(@"AlphabeticalString", FOXArray(FOXAlphabeticalCharacter()));
}

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalStringOfSize(NSUInteger size) {
    return createStringGenerator(@"AlphabeticalStringOfSize", FOXArrayOfSize(FOXAlphabeticalCharacter(), size));
}

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalStringOfSizeRange(NSUInteger minimumSize, NSUInteger maximumSize) {
    return createStringGenerator(@"AlphabeticalStringOfSizeRange", FOXArrayOfSizeRange(FOXAlphabeticalCharacter(), minimumSize, maximumSize));
}

FOX_EXPORT id<FOXGenerator> FOXNumericString(void) {
    return createStringGenerator(@"NumericString", FOXArray(FOXNumericCharacter()));
}

FOX_EXPORT id<FOXGenerator> FOXNumericStringOfSize(NSUInteger size) {
    return createStringGenerator(@"NumericStringOfSize", FOXArrayOfSize(FOXNumericCharacter(), size));
}

FOX_EXPORT id<FOXGenerator> FOXNumericStringOfSizeRange(NSUInteger minimumSize, NSUInteger maximumSize) {
    return createStringGenerator(@"NumericStringOfSizeRange", FOXArrayOfSizeRange(FOXNumericCharacter(), minimumSize, maximumSize));
}

FOX_EXPORT id<FOXGenerator> FOXAlphanumericString(void) {
    return createStringGenerator(@"AlphanumericalString", FOXArray(FOXAlphanumericCharacter()));
}

FOX_EXPORT id<FOXGenerator> FOXAlphanumericStringOfSize(NSUInteger size) {
    return createStringGenerator(@"AlphanumericalStringOfSize", FOXArrayOfSize(FOXAlphanumericCharacter(), size));
}

FOX_EXPORT id<FOXGenerator> FOXAlphanumericStringOfSizeRange(NSUInteger minimumSize, NSUInteger maximumSize) {
    return createStringGenerator(@"AlphanumericalStringOfSizeRange", FOXArrayOfSizeRange(FOXAlphanumericCharacter(), minimumSize, maximumSize));
}

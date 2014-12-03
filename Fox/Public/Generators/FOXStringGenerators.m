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

FOX_EXPORT id<FOXGenerator> FOXString(void) {
    return [[FOXStringGenerator alloc] initWithArrayOfIntegersGenerator:FOXArray(FOXCharacter()) name:@"Any"];
}

FOX_EXPORT id<FOXGenerator> FOXAsciiString(void) {
    return [[FOXStringGenerator alloc] initWithArrayOfIntegersGenerator:FOXArray(FOXAsciiCharacter()) name:@"Ascii"];
}

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalString(void) {
    return [[FOXStringGenerator alloc] initWithArrayOfIntegersGenerator:FOXArray(FOXAlphabeticalCharacter()) name:@"AlphabeticalString"];
}

FOX_EXPORT id<FOXGenerator> FOXAlphanumericString(void) {
    return [[FOXStringGenerator alloc] initWithArrayOfIntegersGenerator:FOXArray(FOXAlphanumericCharacter()) name:@"AlphanumericalString"];
}

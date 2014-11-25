#import "FOXGenericGenerators.h"
#import "FOXCoreGenerators.h"
#import "FOXStringGenerators.h"
#import "FOXNumericGenerators.h"
#import "FOXArrayGenerators.h"
#import "FOXSetGenerators.h"
#import "FOXDictionaryGenerators.h"

FOX_EXPORT id<FOXGenerator> FOXSimpleType(void) {
    return FOXOneOf(@[FOXInteger(),
        FOXCharacter(),
        FOXString(),
        FOXBoolean()]);
}

FOX_EXPORT id<FOXGenerator> FOXPrintableSimpleType(void) {
    return FOXOneOf(@[FOXInteger(),
        FOXAsciiCharacter(),
        FOXAsciiString(),
        FOXBoolean()]);
}

FOX_EXPORT id<FOXGenerator> FOXCompositeType(id<FOXGenerator> itemGenerator) {
    return FOXOneOf(@[FOXArray(itemGenerator),
        FOXSet(itemGenerator)]);
}

FOX_EXPORT id<FOXGenerator> FOXAnyObject(void) {
    NSCAssert(false, @"Not implemented yet");
    return nil;
}

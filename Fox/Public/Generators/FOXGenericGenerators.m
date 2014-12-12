#import "FOXGenericGenerators.h"
#import "FOXCoreGenerators.h"
#import "FOXStringGenerators.h"
#import "FOXNumericGenerators.h"
#import "FOXArrayGenerators.h"
#import "FOXSetGenerators.h"
#import "FOXDictionaryGenerators.h"


FOX_EXPORT id<FOXGenerator> FOXOptional(id<FOXGenerator> generator) {
    return FOXFrequency(@[@[@1, FOXReturn(nil)],
                          @[@3, generator]]);
}

FOX_EXPORT id<FOXGenerator> FOXSimpleType(void) {
    return FOXOneOf(@[FOXInteger(),
                      FOXDouble(),
                      FOXString(),
                      FOXBoolean()]);
}

FOX_EXPORT id<FOXGenerator> FOXPrintableSimpleType(void) {
    return FOXOneOf(@[FOXInteger(),
                      FOXDouble(),
                      FOXAsciiString(),
                      FOXBoolean()]);
}

FOX_EXPORT id<FOXGenerator> FOXCompositeType(id<FOXGenerator> itemGenerator) {
    return FOXOneOf(@[FOXArray(itemGenerator),
                      FOXSet(itemGenerator)]);
}

FOX_EXPORT id<FOXGenerator> FOXAnyObject(void) {
    return FOXOneOf(@[FOXSimpleType(),
                      FOXCompositeType(FOXSimpleType())]);
}

FOX_EXPORT id<FOXGenerator> FOXAnyPrintableObject(void) {
    return FOXOneOf(@[FOXPrintableSimpleType(),
                      FOXCompositeType(FOXPrintableSimpleType())]);
}

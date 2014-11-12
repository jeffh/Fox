#import "PBTGenericGenerators.h"
#import "PBTCoreGenerators.h"
#import "PBTStringGenerators.h"
#import "PBTNumericGenerators.h"
#import "PBTArrayGenerators.h"
#import "PBTSetGenerators.h"
#import "PBTDictionaryGenerators.h"

PBT_EXPORT id<PBTGenerator> PBTSimpleType(void) {
    return PBTOneOf(@[PBTInteger(),
                      PBTCharacter(),
                      PBTString(),
                      PBTBoolean()]);
}

PBT_EXPORT id<PBTGenerator> PBTPrintableSimpleType(void) {
    return PBTOneOf(@[PBTInteger(),
                      PBTAsciiCharacter(),
                      PBTAsciiString(),
                      PBTBoolean()]);
}

PBT_EXPORT id<PBTGenerator> PBTCompositeType(id<PBTGenerator> itemGenerator) {
    return PBTOneOf(@[PBTArray(itemGenerator),
                      PBTSet(itemGenerator)]);
}

PBT_EXPORT id<PBTGenerator> PBTAnyObject(void) {
    NSCAssert(false, @"Not implemented yet");
    return nil;
}

#import "PBTStringGenerators.h"
#import "PBTCoreGenerators.h"
#import "PBTGenerator.h"
#import "PBTStringGenerator.h"
#include "PBTArrayGenerators.h"

PBT_EXPORT id<PBTGenerator> PBTCharacter(void) {
    return PBTWithName(@"Character", PBTChoose(@0, @255));
}

PBT_EXPORT id<PBTGenerator> PBTAlphabetCharacter(void) {
    return PBTWithName(@"AlphabetCharacter", PBTOneOf(@[PBTChoose(@65, @90),
                                                        PBTChoose(@97, @122)]));
}

PBT_EXPORT id<PBTGenerator> PBTNumericCharacter(void) {
    return PBTWithName(@"NumbericCharacter", PBTChoose(@48, @57));
}

PBT_EXPORT id<PBTGenerator> PBTAlphanumericCharacter(void) {
    return PBTWithName(@"AlphanumericCharacter", PBTOneOf(@[PBTChoose(@48, @57),
                                                            PBTChoose(@65, @90),
                                                            PBTChoose(@97, @122)]));
}

PBT_EXPORT id<PBTGenerator> PBTAsciiCharacter(void) {
    return PBTWithName(@"AsciiCharacter", PBTChoose(@32, @126));
}

PBT_EXPORT id<PBTGenerator> PBTString(void) {
    return [[PBTStringGenerator alloc] initWithArrayOfIntegersGenerator:PBTArray(PBTCharacter()) name:@"Any"];
}

PBT_EXPORT id<PBTGenerator> PBTAsciiString(void) {
    return [[PBTStringGenerator alloc] initWithArrayOfIntegersGenerator:PBTArray(PBTAsciiCharacter()) name:@"Ascii"];
}

#import "PBTMacros.h"


@protocol PBTGenerator;


PBT_EXPORT id<PBTGenerator> PBTCharacter(void);

PBT_EXPORT id<PBTGenerator> PBTAlphabetCharacter(void);

PBT_EXPORT id<PBTGenerator> PBTNumericCharacter(void);

PBT_EXPORT id<PBTGenerator> PBTAlphanumericCharacter(void);

PBT_EXPORT id<PBTGenerator> PBTAsciiCharacter(void);

PBT_EXPORT id<PBTGenerator> PBTString(void);

PBT_EXPORT id<PBTGenerator> PBTAsciiString(void);

#import "FOXMacros.h"


@protocol FOXGenerator;


FOX_EXPORT id<FOXGenerator> FOXCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAlphabetCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXNumericCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAlphanumericCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAsciiCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXString(void);

FOX_EXPORT id<FOXGenerator> FOXAsciiString(void);

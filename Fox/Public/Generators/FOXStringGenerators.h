#import "FOXMacros.h"


@protocol FOXGenerator;


FOX_EXPORT id<FOXGenerator> FOXCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXNumericCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAlphanumericCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAsciiCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXString(void);

FOX_EXPORT id<FOXGenerator> FOXAsciiString(void);

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalString(void);

FOX_EXPORT id<FOXGenerator> FOXAlphanumericString(void);

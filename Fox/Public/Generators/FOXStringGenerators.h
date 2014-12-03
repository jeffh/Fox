#import "FOXMacros.h"


@protocol FOXGenerator;


FOX_EXPORT id<FOXGenerator> FOXCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXNumericCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAlphanumericCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAsciiCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXString(void);
FOX_EXPORT id<FOXGenerator> FOXStringOfSize(NSUInteger size);
FOX_EXPORT id<FOXGenerator> FOXStringOfSizeRange(NSUInteger minimumSize, NSUInteger maximumSize);

FOX_EXPORT id<FOXGenerator> FOXAsciiString(void);
FOX_EXPORT id<FOXGenerator> FOXAsciiStringOfSize(NSUInteger size);
FOX_EXPORT id<FOXGenerator> FOXAsciiStringOfSizeRange(NSUInteger minimumSize, NSUInteger maximumSize);

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalString(void);
FOX_EXPORT id<FOXGenerator> FOXAlphabeticalStringOfSize(NSUInteger size);
FOX_EXPORT id<FOXGenerator> FOXAlphabeticalStringOfSizeRange(NSUInteger minimumSize, NSUInteger maximumSize);

FOX_EXPORT id<FOXGenerator> FOXNumericString(void);
FOX_EXPORT id<FOXGenerator> FOXNumericStringOfSize(NSUInteger size);
FOX_EXPORT id<FOXGenerator> FOXNumericStringOfSizeRange(NSUInteger minimumSize, NSUInteger maximumSize);

FOX_EXPORT id<FOXGenerator> FOXAlphanumericString(void);
FOX_EXPORT id<FOXGenerator> FOXAlphanumericStringOfSize(NSUInteger size);
FOX_EXPORT id<FOXGenerator> FOXAlphanumericStringOfSizeRange(NSUInteger minimumSize, NSUInteger maximumSize);

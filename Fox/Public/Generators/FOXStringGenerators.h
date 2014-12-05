#import "FOXMacros.h"


@protocol FOXGenerator;


FOX_EXPORT id<FOXGenerator> FOXCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXNumericCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAlphanumericCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXAsciiCharacter(void);

FOX_EXPORT id<FOXGenerator> FOXString(void);
FOX_EXPORT id<FOXGenerator> FOXStringOfLength(NSUInteger length);
FOX_EXPORT id<FOXGenerator> FOXStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength);

FOX_EXPORT id<FOXGenerator> FOXAsciiString(void);
FOX_EXPORT id<FOXGenerator> FOXAsciiStringOfLength(NSUInteger length);
FOX_EXPORT id<FOXGenerator> FOXAsciiStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength);

FOX_EXPORT id<FOXGenerator> FOXAlphabeticalString(void);
FOX_EXPORT id<FOXGenerator> FOXAlphabeticalStringOfLength(NSUInteger length);
FOX_EXPORT id<FOXGenerator> FOXAlphabeticalStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength);

FOX_EXPORT id<FOXGenerator> FOXNumericString(void);
FOX_EXPORT id<FOXGenerator> FOXNumericStringOfLength(NSUInteger length);
FOX_EXPORT id<FOXGenerator> FOXNumericStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength);

FOX_EXPORT id<FOXGenerator> FOXAlphanumericString(void);
FOX_EXPORT id<FOXGenerator> FOXAlphanumericStringOfLength(NSUInteger length);
FOX_EXPORT id<FOXGenerator> FOXAlphanumericStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength);

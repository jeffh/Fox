#import "FOXMacros.h"


@protocol FOXGenerator;

/*! Creates a generator that produces an NSString containing an arbitrary
 *  character. Characters generated may not be printable.
 */
FOX_EXPORT id<FOXGenerator> FOXCharacter(void);

/*! Creates a generator that produces an NSString containing an arbitrary
 *  alphabetical character (A-Z, a-z).
 */
FOX_EXPORT id<FOXGenerator> FOXAlphabeticalCharacter(void);

/*! Creates a generator that produces an NSString containing an arbitrary
 *  numeric character (0-9).
 */
FOX_EXPORT id<FOXGenerator> FOXNumericCharacter(void);

/*! Creates a generator that produces an NSString containing an arbitrary
 *  alphanumeric character (A-Z, a-z, 0-9).
 */
FOX_EXPORT id<FOXGenerator> FOXAlphanumericCharacter(void);

/*! Creates a generator that produces an NSString containing an arbitrary
 *  human-readable ascii character. (ord 32-126)
 */
FOX_EXPORT id<FOXGenerator> FOXAsciiCharacter(void);

/*! Creates a generator that produces an NSString containing an arbitrary
 *  sequence of characters. Characters generated may not be printable.
 */
FOX_EXPORT id<FOXGenerator> FOXString(void);
FOX_EXPORT id<FOXGenerator> FOXStringOfLength(NSUInteger length);
FOX_EXPORT id<FOXGenerator> FOXStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength);

/*! Creates a generator that produces an NSString containing an arbitrary
 *  sequence of ascii characters (ord 32-126).
 */
FOX_EXPORT id<FOXGenerator> FOXAsciiString(void);
FOX_EXPORT id<FOXGenerator> FOXAsciiStringOfLength(NSUInteger length);
FOX_EXPORT id<FOXGenerator> FOXAsciiStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength);

/*! Creates a generator that produces an NSString containing an arbitrary
 *  sequence of alphabetical characters (A-Z, a-z).
 */
FOX_EXPORT id<FOXGenerator> FOXAlphabeticalString(void);
FOX_EXPORT id<FOXGenerator> FOXAlphabeticalStringOfLength(NSUInteger length);
FOX_EXPORT id<FOXGenerator> FOXAlphabeticalStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength);

/*! Creates a generator that produces an NSString containing an arbitrary
 *  sequence of numeric characters (0-9).
 */
FOX_EXPORT id<FOXGenerator> FOXNumericString(void);
FOX_EXPORT id<FOXGenerator> FOXNumericStringOfLength(NSUInteger length);
FOX_EXPORT id<FOXGenerator> FOXNumericStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength);

/*! Creates a generator that produces an NSString containing an arbitrary
 *  sequence of alphanumeric characters (A-Z, a-z, 0-9).
 */
FOX_EXPORT id<FOXGenerator> FOXAlphanumericString(void);
FOX_EXPORT id<FOXGenerator> FOXAlphanumericStringOfLength(NSUInteger length);
FOX_EXPORT id<FOXGenerator> FOXAlphanumericStringOfLengthRange(NSUInteger minimumLength, NSUInteger maximumLength);

#import "FOXMacros.h"

@protocol FOXGenerator;


/*! Creates a generator that produces random BOOLs (boxed as NSNumbers).
 *  Shrinks towards NO.
 *
 *  @returns a generator that produces BOOLs (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXBoolean(void);


/*! Creates a generator that produces random NSIntegers (boxed as NSNumbers).
 *  Shrinks towards zero.
 *
 *  The size hint dictates the min & max integer values that can be generated.
 *
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXInteger(void);

/*! Creates a generator that produces random positive NSIntegers (boxed as
 *  NSNumbers). Includes zero. Shrinks towards 0.
 *
 *  The size hint dictates the min & max integer values that can be generated,
 *  bounding to 0 as the minimum.
 *
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXPositiveInteger(void);

/*! Creates a generator that produces random positive NSIntegers (boxed as
 *  NSNumbers). Does not include zero. Shrinks towards 1.
 *
 *  The size hint dictates the min & max integer values that can be generated,
 *  bounding to 1 as the minimum.
 *
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXStrictPositiveInteger(void);

/*! Creates a generator that produces random negative NSIntegers (boxed as
 *  NSNumbers). Includes zero. Shrinks towards 0.
 *
 *  The size hint dictates the min & max integer values that can be generated,
 *  bounding to 0 as the maximum.
 *
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXNegativeInteger(void);

/*! Creates a generator that produces random negative NSIntegers (boxed as
 *  NSNumbers). Does not include zero. Shrinks towards -1.
 *
 *  The size hint dictates the min & max integer values that can be generated,
 *  bounding to -1 as the maximum.
 *
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXStrictNegativeInteger(void);


/*! Creates a generator that produces random floats (boxed as NSNumbers).
 *  Shrinks towards zero. Floats generated conform to IEEE standard.
 *
 *  The size hint dictates the min & max values that can be generated.
 *
 *  @returns a generator that produces floats (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXFloat(void);

/*! Creates a generator that produces random doubles (boxed as NSNumbers).
 *  Shrinks towards zero. Doubles generated conform to IEEE standard.
 *
 *  The size hint dictates the min & max values that can be generated.
 *
 *  @returns a generator that produces doubles (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXDouble(void);

/*! Creates a generator that produces random decimal numbers.
 *  Shrinks towards [NSDecimalNumber zero].
 *
 *  The size hint dictates the min & max values that can be generated.
 *
 *  @returns a generator that produces NSDecimalNumbers.
 */
FOX_EXPORT id<FOXGenerator> FOXDecimalNumber(void);

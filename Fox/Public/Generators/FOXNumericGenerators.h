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
 *  @seealso FOXFamousInteger
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXInteger(void);

/*! Creates a generator that produces random positive NSIntegers (boxed as
 *  NSNumbers). Includes zero. Shrinks towards 0.
 *
 *  The size hint dictates the min & max integer values that can be generated,
 *  bounding to 0 as the minimum.
 *
 *  @seealso FOXFamousPositiveInteger
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXPositiveInteger(void);

/*! Creates a generator that produces random positive NSIntegers (boxed as
 *  NSNumbers). Does not include zero. Shrinks towards 1.
 *
 *  The size hint dictates the min & max integer values that can be generated,
 *  bounding to 1 as the minimum.
 *
 *  @seealso FOXFamousStrictPositiveInteger
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXStrictPositiveInteger(void);

/*! Creates a generator that produces random negative NSIntegers (boxed as
 *  NSNumbers). Includes zero. Shrinks towards 0.
 *
 *  The size hint dictates the min & max integer values that can be generated,
 *  bounding to 0 as the maximum.
 *
 *  @seealso FOXFamousNegativeInteger
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXNegativeInteger(void);

/*! Creates a generator that produces random negative NSIntegers (boxed as
 *  NSNumbers). Does not include zero. Shrinks towards -1.
 *
 *  The size hint dictates the min & max integer values that can be generated,
 *  bounding to -1 as the maximum.
 *
 *  @seealso FOXFamousStrictNegativeInteger
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXStrictNegativeInteger(void);

/*! Creates a generator that produces random NSIntegers (boxed as NSNumbers).
 *  Does not include zero. Shrinks towards 1.
 *
 *  The size hint dictates the min & max integer values that can be generated.
 *
 *  @seealso FOXFamousNonZeroInteger
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXNonZeroInteger(void);

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


/*! Creates a generator that produces random NSIntegers with an increased
 *  probability of picking INT_MAX and INT_MIN. Shrinks towards 0.
 *
 *  The size hint dictates the min & max values that can be generated. This is
 *  ignored if INT_MAX or INT_MIN was probabilitically picked.
 *
 *  @warning Since this generator can produce large numbers, it is not
 *           recommended to use this generator to produce collections.
 *
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXFamousInteger(void);

/*! Creates a generator that produces random positive NSIntegers with an
 *  increased probability of picking INT_MAX. Shrinks towards 0.
 *
 *  The size hint dictates the min & max values that can be generated. This is
 *  ignored if INT_MAX was probabilitically picked.
 *
 *  @warning Since this generator can produce large numbers, it is not
 *           recommended to use this generator to produce collections.
 *
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXFamousPositiveInteger(void);

/*! Creates a generator that produces random negative NSIntegers with an
 *  increased probability of picking INT_MIN. Shrinks towards 0.
 *
 *  The size hint dictates the min & max values that can be generated. This is
 *  ignored if INT_MIN was probabilitically picked.
 *
 *  @warning Since this generator can produce large numbers, it is not
 *           recommended to use this generator to produce collections.
 *
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXFamousNegativeInteger(void);

/*! Creates a generator that produces random negative NSIntegers with an
 *  increased probability of picking INT_MIN. Does not include zero.
 *  Shrinks towards -1.
 *
 *  The size hint dictates the min & max values that can be generated. This is
 *  ignored if INT_MIN was probabilitically picked.
 *
 *  @warning Since this generator can produce large numbers, it is not
 *           recommended to use this generator to produce collections.
 *
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXFamousStrictNegativeInteger(void);

/*! Creates a generator that produces random positive NSIntegers with an
 *  increased probability of picking INT_MAX. Does not include zero.
 *  Shrinks towards -1.
 *
 *  The size hint dictates the min & max values that can be generated. This is
 *  ignored if INT_MAX was probabilitically picked.
 *
 *  @warning Since this generator can produce large numbers, it is not
 *           recommended to use this generator to produce collections.
 *
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXFamousStrictPositiveInteger(void);

/*! Creates a generator that produces random NSIntegers with an increased
 *  probability of picking INT_MAX or INT_MIN. Does not include zero.
 *  Shrinks towards 1.
 *
 *  The size hint dictates the min & max values that can be generated. This is
 *  ignored if INT_MAX or INT_MIN was probabilitically picked.
 *
 *  @warning Since this generator can produce large numbers, it is not
 *           recommended to use this generator to produce collections.
 *
 *  @returns a generator that produces integers (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXFamousNonZeroInteger(void);

/*! Creates a generator that produces random floats (boxed as NSNumbers) with
 *  an increased probability of choosing extreme values (NaN, INFINITY,
 *  -INFINITY, -0, MAX, MIN). Shrinks towards zero. Doubles generated conform to
 *  IEEE standard.
 *
 *  The size hint dictates the min & max values that can be generated with the
 *  exception of extreme values.
 *
 *  @returns a generator that produces floats (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXFamousFloat(void);

/*! Creates a generator that produces random doubles (boxed as NSNumbers) with
 *  an increased probability of choosing extreme values (NaN, INFINITY,
 *  -INFINITY, -0, MIN, MAX). Shrinks towards zero. Doubles generated conform to
 *  IEEE standard.
 *
 *  The size hint dictates the min & max values that can be generated with the
 *  exception of extreme values.
 *
 *  @returns a generator that produces doubles (boxed in NSNumbers).
 */
FOX_EXPORT id<FOXGenerator> FOXFamousDouble(void);

/*! Creates a generator that produces random decimal numbers with an increased
 *  probability of choosing extreme values (NaN, MIN, MAX).
 *  Shrinks towards [NSDecimalNumber zero].
 *
 *  The size hint dictates the min & max values that can be generated with the
 *  exception of extreme values.
 *
 *  @returns a generator that produces NSDecimalNumbers.
 */
FOX_EXPORT id<FOXGenerator> FOXFamousDecimalNumber(void);

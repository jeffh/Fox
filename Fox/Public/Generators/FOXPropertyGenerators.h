#import "FOXMacros.h"
#import "FOXPropertyResult.h"


@protocol FOXGenerator;

/*! Creates a generator that maps an assertion block against input from a
 *  generator.
 *
 *  @param generator A generator used as input for the assertion block.
 *  @param then A block that asserts against the generator.
 *  @returns A generator of FOXPropertyResult values.
 */
FOX_EXPORT id<FOXGenerator> FOXForAll(id<FOXGenerator> generator, BOOL (^then)(id generatedValue));

/*! Creates a generator that maps an assertion block against input from a
 *  generator. The assertion block that choose to skip a block.
 *
 *  @param generator A generator used as input for the assertion block.
 *  @param then A block that asserts against the generator.
 *  @returns A generator of FOXPropertyResult values.
 */
FOX_EXPORT id<FOXGenerator> FOXForSome(id<FOXGenerator> generator, FOXPropertyStatus (^then)(id generatedValue));

/*! Creates a generator that retries the given property generator a number of
 *  times. The failed property is returned if any one of the attempts fails.
 *
 *  This is generally useful for tests that are unreliably failing (eg -
 *  parallel tests).
 *
 *  @param times The number of times to run the property.
 *  @param property The property to retry multiple times.
 */
FOX_EXPORT id<FOXGenerator> FOXAlways(NSUInteger times, id<FOXGenerator> property);

#if !defined(FOX_DISABLE_SHORTHAND)
/*! Creates a generator that maps an assertion block against input from a
 *  generator.
 *
 *  @param generator A generator used as input for the assertion block.
 *  @param then A block that asserts against the generator.
 *  @returns A generator of FOXPropertyResult values.
 */
FOX_INLINE id<FOXGenerator> forAll(id<FOXGenerator> generator, BOOL (^then)(id generatedValue)) {
    return FOXForAll(generator, then);
}

/*! Creates a generator that maps an assertion block against input from a
 *  generator. The assertion block that choose to skip a block.
 *
 *  @param generator A generator used as input for the assertion block.
 *  @param then A block that asserts against the generator.
 *  @returns A generator of FOXPropertyResult values.
 */
FOX_INLINE id<FOXGenerator> forSome(id<FOXGenerator> generator, FOXPropertyStatus (^then)(id generatedValue)) {
    return FOXForSome(generator, then);
}
#endif

#import "FOXMacros.h"

@protocol FOXGenerator;

/*! Produces a generator that has a chance to return nil instead of the
 * original generator.
 *
 * @param generator The generator that produces values other than nil.
 * @returns a new generator that has a 25% chance to return nil. Shrinks to nil.
 */
FOX_EXPORT id<FOXGenerator> FOXOptional(id<FOXGenerator> generator);

/*! Generates a random non-composite type: integers, floats, characters,
 *  strings, boolean. Generates values may not be printable.
 */
FOX_EXPORT id<FOXGenerator> FOXSimpleType(void);

/*! Generates a random non-composite type: integers, floats, characters,
 *  strings, boolean. Generates values that are ensured to be printable.
 */
FOX_EXPORT id<FOXGenerator> FOXPrintableSimpleType(void);

/*! Generates a random composite type: arrays, sets using the given generator
 *  as an item.
 */
FOX_EXPORT id<FOXGenerator> FOXCompositeType(id<FOXGenerator> itemGenerator);

/*! Generates a random objects that FOXSimpleType() and FOXCompositeType()
 *  generates.
 */
FOX_EXPORT id<FOXGenerator> FOXAnyObject(void);

/*! Generates a random objects that FOXPrinableSimpleType() and
 *  FOXCompositeType() generates.
 */
FOX_EXPORT id<FOXGenerator> FOXAnyPrintableObject(void);

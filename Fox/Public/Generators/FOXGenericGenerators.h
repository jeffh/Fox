#import "FOXMacros.h"

@protocol FOXGenerator;

/*! Produces a generator that has a chance to return nil instead of the
 * original generator.
 *
 * @param generator The generator that produces values other than nil.
 * @returns a new generator that has a 25% chance to return nil. Shrinks to nil.
 */
FOX_EXPORT id<FOXGenerator> FOXOptional(id<FOXGenerator> generator);

/// Generates a random non-composite type: integers, floats, strings.
FOX_EXPORT id<FOXGenerator> FOXSimpleType(void);

FOX_EXPORT id<FOXGenerator> FOXPrintableSimpleType(void);

FOX_EXPORT id<FOXGenerator> FOXCompositeType(id<FOXGenerator> itemGenerator);

FOX_EXPORT id<FOXGenerator> FOXAnyObject(void);

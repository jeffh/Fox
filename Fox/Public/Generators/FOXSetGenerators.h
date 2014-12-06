#import "FOXMacros.h"


@protocol FOXGenerator;

/*! Produces randomly-sized sets using the given generator.
 *  The generator must produces values that are equatable.
 *
 *  @param elementGenerator The generator that will produce elements for the
 *                          set. Must produce objects that support the methods
 *                          required to be in a set.
 *  @returns a generator that produces sets using the given genrator.
 */
FOX_EXPORT id<FOXGenerator> FOXSet(id<FOXGenerator> elementGenerator);

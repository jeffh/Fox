#import "FOXMacros.h"


@protocol FOXGenerator;
@protocol FOXSequence;


/*! Generates a fixed-size array where each element is in the same order
 *  as the specified sequence of generators.
 *
 *  @param generators A sequence of generators that corresponds to each
 *                    element's generator.
 *  @returns a generator that produces a fixed-size array
 */
FOX_EXPORT id<FOXGenerator> FOXTupleOfGenerators(id<FOXSequence> generators);

/*! Generates a fixed-size array where each element is in the same order
 *  as the specified sequence of generators.
 *
 *  @param generators An array of generators that corresponds to each element's
 *                    generator.
 *  @returns a generator that produces a fixed-size array.
 */
FOX_EXPORT id<FOXGenerator> FOXTuple(NSArray *generators);

/*! Generates a variable-size array with each element generated from the given
 *  generator.
 *
 *  @param elementGenerator The generator used to produce each element in the
 *                          generated array.
 *  @returns a generator that produces a variable-size array.
 */
FOX_EXPORT id<FOXGenerator> FOXArray(id<FOXGenerator> elementGenerator);

/*! Generates a fixed-size array with each element generated from the given
 *  generator.
 *
 *  @param elementGenerator The generator used to produce each element in the
 *                          generated array.
 *  @returns a generator that produces a fixed-size array.
 */
FOX_EXPORT id<FOXGenerator> FOXArrayOfSize(id<FOXGenerator> elementGenerator, NSUInteger numberOfElements);

/*! Generates a variable-size array with each element generated from the given
 *  generator. The array is within the given size range (inclusive).
 *
 *  @param elementGenerator The generator used to produce each element in the
 *                          generated array.
 *  @returns a generator that produces a variable-size array within the given
 *           size constraints.
 */
FOX_EXPORT id<FOXGenerator> FOXArrayOfSizeRange(
    id<FOXGenerator> elementGenerator,
    NSUInteger minimumNumberOfElements,
    NSUInteger maximumNumberOfElements);


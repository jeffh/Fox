#import "FOXMacros.h"


@class FOXRoseTree;
@protocol FOXGenerator;
@protocol FOXRandom;

typedef struct {
    NSInteger start;
    NSInteger end;
} FOXRange;

/*! Creates a generator with a -[description] to help debugging.
 */
FOX_EXPORT id<FOXGenerator> FOXWithName(NSString *name, id<FOXGenerator> generator);

/*! Creates a generator that conforms to the FOXGenerator protocol.
 */
FOX_EXPORT id<FOXGenerator> FOXGenerate(FOXRoseTree *(^generator)(id<FOXRandom> random, NSUInteger size));

/*! Creates a generator that always returns the given rose tree.
 */
FOX_EXPORT id<FOXGenerator> FOXGenPure(FOXRoseTree *tree);

/*! Creates a generator that applies the given block to another generator.
 *  This effectively "chains" operations on existing generators.
 *
 *  @param generator The generator whose rose tree is modified post-generation.
 *  @param mapfn The block that transforms the rose tree of the given generator
 *               produced into the resulting rose tree that is returned by the
 *               generator that FOXGenMap creates.
 *  @returns a generator that applies the given block to the rose tree of the
 *           given generator.
 */
FOX_EXPORT id<FOXGenerator> FOXGenMap(
    id<FOXGenerator> generator,
    FOXRoseTree *(^mapfn)(FOXRoseTree *generatedTree));

/*! Creates a generator that takes the rose tree of another generator as input.
 *
 *  @param generator The generator whose rose tree is used as input.
 *  @param generatorFactory The factory that produces a generator given the
 *                          rose tree of the given generator.
 *  @returns the generator created by the generatorFactory block.
 */
FOX_EXPORT id<FOXGenerator> FOXGenBind(
    id<FOXGenerator> generator,
    id<FOXGenerator> (^generatorFactory)(FOXRoseTree *generatedTree));

/*! Creates a generator by applying the block to each value produced by the
 *  given generator. This is a higher abstraction than FOXGenMap.
 *
 *  @param generator The generator whose values will be transformed.
 *  @param fn The block that transforms values generated.
 *  @returns a generator that produces rose trees with fn applied.
 */
FOX_EXPORT id<FOXGenerator> FOXMap(id<FOXGenerator> generator, id(^fn)(id generatedValue));

/*! Creates a generator that takes another generator's generated values as
 *  input. This is a higher abstraction than FOXGenBind
 *
 *  @param generator The generator whose values will be used as input.
 *  @param fn The factory block that produces a new generator given the other
 *            generator's values as input.
 *  @returns the generator produced by fn.
 */
FOX_EXPORT id<FOXGenerator> FOXBind(id<FOXGenerator> generator, id<FOXGenerator> (^fn)(id generatedValue));

/*! Creates a generator that randomly picks numbers within the given range
 *  (inclusive). Shrinks towards the lower-bound number.
 *
 *  @param lower The lower bound integer that can be generated (inclusive).
 *  @param upper The upper bound integer that can be generated (inclusive).
 *  @returns a generator that produces integers (boxed as NSNumber *)
 */
FOX_EXPORT id<FOXGenerator> FOXChoose(NSNumber *lower, NSNumber *upper);

/*! Creates a generator that takes the size hint as input. This is useful
 *  when the generator creation relies in the size parameter.
 *
 *  @param fn The factory block that produces the generator with the intended
 *            size hint as its parameter.
 *  @returns the generator produced by fn.
 */
FOX_EXPORT id<FOXGenerator> FOXSized(id<FOXGenerator> (^fn)(NSUInteger size));

/*! Creates a generator that always returns the given value. This is a higher
 *  abstraction than FOXGenPure. This generator does not support shrinking.
 *
 *  @param value The value that is always returned.
 *  @returns a generator that always returns value and never shrinks.
 */
FOX_EXPORT id<FOXGenerator> FOXReturn(id value);

/*! Creates a generator that produces values of the given generator, but
 *  filters out values that do not satisfy a predicate block.
 *
 *  This function will raise an exception if 10 values are filtered in a row.
 *  @see FoxSuchThatWithMaxTries to increase this if needed.
 *
 *  @warning This is inefficient and tosses away generated data. Avoid using
 *           this when possible.
 *
 *  @param generator The generator whose values will be filtered.
 *  @param predicate The block that indicates if values are dropped by returning
 *                   NO.
 *  @returns a generator that produces values of the original generator filtered
 *           by predicate.
 */
FOX_EXPORT id<FOXGenerator> FOXSuchThat(id<FOXGenerator> generator, BOOL(^predicate)(id generatedValue));

/*! Creates a generator that produces values of the given generator, but
 *  filters out values that do not satisfy a predicate block.
 *
 *  This function will raise an exception if more values are filtered in a row
 *  than maxTries.
 *
 *  @warning This is inefficient and tosses away generated data. Avoid using
 *           this when possible.
 *
 *  @param generator The generator whose values will be filtered.
 *  @param predicate The block that indicates if values are dropped by returning
 *                   NO.
 *  @param maxTries The maximum number of values to be dropped in a row before
 *                  aborting by raising an exception.
 *  @returns a generator that produces values of the original generator filtered
 *           by predicate.
 */
FOX_EXPORT id<FOXGenerator> FOXSuchThatWithMaxTries(id<FOXGenerator> generator, BOOL(^predicate)(id generatedValue), NSUInteger maxTries);

/*! Creates a generator that randomly picks one of the given generators.
 *  Shrinking is dependent on the given generator. FOXOneOf will not switch the
 *  generator that caused the failued during shrinking.
 *
 *  Generators are picked evenly.
 *  @see FOXFrequency if you want to pick generators unevenly.
 *
 *  @param generators An array of generators to select from.
 *  @returns a generator that randomly uses one of the generators its provided.
 */
FOX_EXPORT id<FOXGenerator> FOXOneOf(NSArray *generators);

/*! Creates a generator that randomly picks one of the given elements in the
 *  provided array. The generator will shrink to elements with a lower index
 *  in the array.
 *
 *  @param elements An array of objects to pick from when generating values.
 *  @returns a generator that randomly returns one of the values in elements.
 */
FOX_EXPORT id<FOXGenerator> FOXElements(NSArray *elements);

/*! Creates a generator that radomly picks one of the given generators based on
 *  weighted frequencies.
 *
 *  The percent chance of selecting an element is based on the sum of all the
 *  weights.
 *
 *  @param An array of 2-element arrays: [(NSNumber, id<FOXGenerator>)] where
 *         the number is an unsigned integer indicating the likelihood of
 *         being selected.
 *  @returns a generator that randomly uses a given generator based on weighted
 *           frequencies.
 */
FOX_EXPORT id<FOXGenerator> FOXFrequency(NSArray *tuples);

/*! Creates a generator that overrides the runtime size for the given generator.
 *  This can prevent shrinking for the given generator.
 *
 *  @param generator The generator that will use the newSize when producing
 *                   values.
 *  @param newSize the new size to provide to the given generator.
 *  @returns a new generator that produces values from the given generator at
 *           the specified size.
 */
FOX_EXPORT id<FOXGenerator> FOXResize(id<FOXGenerator> generator, NSUInteger newSize);

/*! Creates a generator that overrides the runtime size for the given generator.
 *  This generator will shrink to the lower bound size specified, but can still
 *  restrict the shrinking capabilities of the given generator.
 *
 *  @param generator The generator that will use the a size in the given range
 *                   when generating values.
 *  @param minimumRange The minimum size that can be used for the given
 *                      generator (inclusive).
 *  @param maximumRange The maximum size that can be used for the given
 *                      generator (inclusive).
 *  @returns a generor that produces values from the given genrator within the
 *           given size range.
 */
FOX_EXPORT id<FOXGenerator> FOXResizeRange(id<FOXGenerator> generator, NSUInteger minimumRange, NSUInteger maximumRange);

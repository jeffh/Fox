#import "FOXMacros.h"

@protocol FOXGenerator;

/*! Samples from a generator to see what values it produces. Useful for debugging.
 *
 *  @param generator The generator to sample.
 *  @returns an array of 10 items. nils that the generator produces are boxed.
 */
FOX_EXPORT NSArray *FOXSample(id<FOXGenerator> generator);


/*! Samples from a generator to see what values it produces. Useful for debugging.
 *
 *  @param generator The generator to sample.
 *  @param numberOfSamples The number of samples to take.
 *  @returns an array of size requested. nils that the generator produces are boxed.
 */
FOX_EXPORT NSArray *FOXSampleWithCount(id<FOXGenerator> generator, NSUInteger numberOfSamples);

/*! Samples a generated value produced from a generator. Useful to see how the generator shrinks its values.
 *
 *  @param generator The generator to sample its shrinking behavior
 *  @returns an array of up to 10 items. nils that the generator produces are boxed. The first element is the generated value with subsequent values smaller than the first one.
 */
FOX_EXPORT NSArray *FOXSampleShrinking(id<FOXGenerator> generator);


/*! Samples a generated value produced from a generator. Useful to see how the generator shrinks its values.
 *
 *  @warning Generators are allowed to generate infinite rose trees, so be careful if you choose a large sample size.
 *
 *  @param generator The generator to sample its shrinking behavior.
 *  @param numberOfSamples The number of samples to take. Increasing this shows more of the shrinking tree.
 *  @returns an array of up to 10 items. nils that the generator produces are boxed. The first element is the generated value with subsequent values smaller than the first one.
 */
FOX_EXPORT NSArray *FOXSampleShrinkingWithCount(id<FOXGenerator> generator, NSUInteger numberOfSamples);

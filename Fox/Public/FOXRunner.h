#import "FOXMacros.h"

@class FOXRunnerResult;
@protocol FOXGenerator;
@protocol FOXReporter;
@protocol FOXRandom;


/*! A constant that indicates the default number of tests (which is 500) */
FOUNDATION_EXTERN const NSUInteger FOXDefaultNumberOfTests;

/*! A constant that indicates the default maximum size (which is 200).
 *
 *  The maximum size factor that generators will generate. A size value is generated
 *  by FOX as the size the generators in the properties use. The maximum size factor
 *  indicates a broader range of data values at the potential cost of computation.
 *
 *  Two examples: generating integers and arrays. The maximum size value indicates the
 *  minimum and maximum values the FOXInteger() generator can create. For array generation,
 *  the size indicates how large each element is (eg - large integers) AND how many
 *  elements are generated.
 */
FOUNDATION_EXTERN const NSUInteger FOXDefaultMaximumSize;

/*! Samples from a generator to see what values it produces. Useful for debugging.
 *  @returns an array of 10 items. nils that the generator produces are boxed.
 */
FOX_EXPORT NSArray *FOXSample(id<FOXGenerator> generator);


/*! Samples from a generator to see what values it produces. Useful for debugging.
 *  @returns an array of size requested. nils that the generator produces are boxed.
 */
FOX_EXPORT NSArray *FOXSampleWithCount(id<FOXGenerator> generator, NSUInteger numberOfSamples);

/*! Generates random data and uses it to test properties.
 */
@interface FOXRunner : NSObject

/*! A runner may optionally be instantiated with a reporter object.
 *  This reporter receives messages regarding the state of the runner,
 *  and may use these opportunities to print to the console or write to a file.
 *  In the case the runner is not instantiated with a reporter, this is nil.
 */
@property (nonatomic, readonly, strong) id <FOXReporter> reporter;

/*! Returns the singleton runner used by FOXAssert assertions.
 */
+ (instancetype)sharedInstance;

/*! Convenience initializer.
 *
 *  @returns A runner that uses a deterministic randomness generator and no reporter.
 */
- (instancetype)init;

/*! Convenience initializer.
 *
 *  @param reporter The reporter object that is sent messages regarding the state of the runner. This may be nil.
 *  @returns A runner with the given reporter, that uses a deterministic randomness generator.
 */
- (instancetype)initWithReporter:(id<FOXReporter>)reporter;

/*! Designated initializer.
 *
 *  @param reporter The reporter object that is sent messages regarding the state of the runner. This may be nil.
 *  @param random An object that provides the runner with randomness.
 */
- (instancetype)initWithReporter:(id<FOXReporter>)reporter random:(id<FOXRandom>)random;

/*! Tests the given property.
 *
 *  @param numberOfTests The number of times the property is tested against random data.
 *  @param property The property to be tested.
 *  @returns The results of the set of tests on the property.
 */
- (FOXRunnerResult *)resultForNumberOfTests:(NSUInteger)numberOfTests
                                   property:(id<FOXGenerator>)property;
- (FOXRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                   property:(id<FOXGenerator>)property
                                       seed:(uint32_t)seed;
- (FOXRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                   property:(id<FOXGenerator>)property
                                       seed:(uint32_t)seed
                                    maxSize:(NSUInteger)maxSize;

@end



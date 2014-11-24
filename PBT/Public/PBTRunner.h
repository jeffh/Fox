#import "PBTGenerator.h"
#import "PBTPropertyGenerators.h"
#import "PBTReporter.h"

/*! A constant that indicates the default number of tests (which is 500) */
FOUNDATION_EXTERN const NSUInteger PBTDefaultNumberOfTests;

/*! A constant that indicates the default maximum size (which is 200).
 *
 *  The maximum size factor that generators will generate. A size value is generated
 *  by PBT as the size the generators in the properties use. The maximum size factor
 *  indicates a broader range of data values at the potential cost of computation.
 *
 *  Two examples: generating integers and arrays. The maximum size value indicates the
 *  minimum and maximum values the PBTInteger() generator can create. For array generation,
 *  the size indicates how large each element is (eg - large integers) AND how many
 *  elements are generated.
 */
FOUNDATION_EXTERN const NSUInteger PBTDefaultMaximumSize;


@class PBTRunnerResult;

/*! Generates random data and uses it to test properties.
 */
@interface PBTRunner : NSObject

/*! A runner may optionally be instantiated with a reporter object.
 *  This reporter receives messages regarding the state of the runner,
 *  and may use these opportunities to print to the console or write to a file.
 *  In the case the runner is not instantiated with a reporter, this is nil.
 */
@property (nonatomic, readonly, strong) id <PBTReporter> reporter;

/*! Returns the singleton runner used by PBTAssert assertions.
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
- (instancetype)initWithReporter:(id<PBTReporter>)reporter;

/*! Designated initializer.
 *
 *  @param reporter The reporter object that is sent messages regarding the state of the runner. This may be nil.
 *  @param random An object that provides the runner with randomness.
 */
- (instancetype)initWithReporter:(id<PBTReporter>)reporter random:(id<PBTRandom>)random;

/*! Tests the given property.
 *
 *  @param numberOfTests The number of times the property is tested against random data.
 *  @param property The property to be tested.
 *  @returns The results of the set of tests on the property.
 */
- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)numberOfTests
                                   property:(id<PBTGenerator>)property;
- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)numberOfTests
                                    forSome:(id<PBTGenerator>)values
                                       then:(PBTPropertyStatus (^)(id generatedValue))then;
- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                   property:(id<PBTGenerator>)property
                                       seed:(uint32_t)seed;
- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                   property:(id<PBTGenerator>)property
                                       seed:(uint32_t)seed
                                    maxSize:(NSUInteger)maxSize;

@end



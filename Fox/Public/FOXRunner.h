#import "FOXMacros.h"

@class FOXRunnerResult;
@protocol FOXGenerator;
@protocol FOXReporter;
@protocol FOXRandom;



#pragma mark - FOXRunner

/*! Generates random data and uses it to test properties.
 */
@interface FOXRunner : NSObject

/*! A runner may optionally be instantiated with a reporter object.
 *  This reporter receives messages regarding the state of the runner,
 *  and may use these opportunities to print to the console or write to a file.
 *  In the case the runner is not instantiated with a reporter, this is nil.
 *
 *  It is not recommended to regularly write to this property. This property is
 *  writable to allow you to customize the +[assertInstance].
 */
@property (nonatomic) id<FOXReporter> reporter;

/*! A runner is instatiated with a random object.
 *  This randomizer is used for generators to assist in producing arbitrary data.
 *
 *  It is not recommended to regularly write to this property. This property is
 *  writable to allow you to customize the +[assertInstance].
 */
@property (nonatomic) id<FOXRandom> random;

/*! Returns the singleton runner used by FOXAssert assertions.
 */
+ (instancetype)assertInstance;

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
                                       seed:(NSUInteger)seed;
- (FOXRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                   property:(id<FOXGenerator>)property
                                       seed:(NSUInteger)seed
                                    maxSize:(NSUInteger)maxSize;

@end



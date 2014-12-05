#import <Foundation/Foundation.h>


@class FOXRunnerResult;
@class FOXPropertyResult;


/*! An object conforming to this protocol is able to receive updates on the current status
 *  of a FOXRunner. Reporters may present these statuses to the user, for example, by
 *  printing them to stdout or writing information about them to a file.
 *
 *  For an example of a concrete implementation, see FOXStandardReporter.
 */
@protocol FOXReporter<NSObject>

/*! A message sent to indicate that the runner is about to begin a run using the given
 *  seed.
 *
 *  @param randomSeed The seed used to generate random data for the
 *                    run that is about to begin.
 */
- (void)runnerWillRunWithSeed:(NSUInteger)randomSeed;

/*! A message sent to indicate that the runner is about to verify a property.
 *
 *  @param testNumber The number of the current test of the property. That is, if the
 *                    property is verified against random data 300 times, and this message
 *                    corresponds to the 299th time that property is tested, this
 *                    parameter will have the value of 298 (not 299 because it is
 *                    zero-indexed).
 *  @param maxSize The maximum size used when generating random values.
 */
- (void)runnerWillVerifyTestNumber:(NSUInteger)testNumber
                   withMaximumSize:(NSUInteger)maxSize;

/*! A message sent to indicate that Fox skipped an individual test for a property with
 *  random data. Skipping tests can occur when PBTPropertyStatusSkipped is returned by an
 *  assertion.
 *
 *  @param testNumber The number of the current test of the property. That is, if the
 *                    property is verified against random data 300 times, and this message
 *                    corresponds to the 299th time that property is tested, this
 *                    parameter will have the value of 298 (not 299 because it is
 *                    zero-indexed).
 *  @param result The result of the individual test of the property. The status of that
 *                result is (of course) skipped, but it also contains information such as
 *                the randomly generated value that caused the property to skipped.
 */
- (void)runnerDidSkipTestNumber:(NSUInteger)testNumber
                 propertyResult:(FOXPropertyResult *)result;

/*! A message sent to indicate that a property passed an individual test with random data.
 *
 *  @param testNumber The number of the current test of the property. That is, if the
 *                    property is verified against random data 300 times, and this message
 *                    corresponds to the 299th time that property is tested, this
 *                    parameter will have the value of 298 (not 299 because it is
 *                    zero-indexed).
 *  @param result The result of the individual test of the property. The status of that
 *                result is (of course) passing, but it also contains information such as
 *                the randomly generated value that caused the property to succeed.
 */
- (void)runnerDidPassTestNumber:(NSUInteger)testNumber
                 propertyResult:(FOXPropertyResult *)result;

/*! A message sent to indicate that the property being tested failed a test, and is about
 *  to be shrunk in order to find the smallest failing value.
 *
 *  @param testNumber The number of the current test of the property. That is, if the
 *                    property is verified against random data 300 times, and this message
 *                    corresponds to the 299th time that property is tested, this
 *                    parameter will have the value of 298 (not 299 because it is
 *                    zero-indexed).
 *  @param result The result of the individual test of the property. The status of that
 *                result is (of course) a failure, but it also contains information such
 *                as the randomly generated value that caused the property to fail.
 */
- (void)runnerWillShrinkFailingTestNumber:(NSUInteger)testNumber
                 failedWithPropertyResult:(FOXPropertyResult *)result;

/*! A message sent to indicate that the value sent to a property in order to cause it to
 *  fail has been shrunk.
 *
 *  @param testNumber The number of the current test of the property. That is, if the
 *                    property is verified against random data 300 times, and this message
 *                    corresponds to the 299th time that property is tested, this
 *                    parameter will have the value of 298 (not 299 because it is
 *                    zero-indexed).
 *  @param result The result of the individual test of the property. The status of that
 *                result is (of course) a failure, but it also contains information such
 *                as the randomly generated value that caused the property to fail.
 */
- (void)runnerDidShrinkFailingTestNumber:(NSUInteger)testNumber
                      withPropertyResult:(FOXPropertyResult *)result;

/*! A message sent to indicate that a property failed an individual test with random data.
 *
 *  @param testNumber The number of the current test of the property. That is, if the
 *                    property is verified against random data 300 times, and this message
 *                    corresponds to the 299th time that property is tested, this
 *                    parameter will have the value of 298 (not 299 because it is
 *                    zero-indexed).
 *  @param result The result of the individual test of the property. The status of that
 *                result is (of course) a failure, but it also contains information such
 *                as the randomly generated value that caused the property to fail.
 */
- (void)runnerDidFailTestNumber:(NSUInteger)testNumber
                     withResult:(FOXRunnerResult *)result;

/*! A message sent to indicate that a property passed all the tests Fox generated.
 *
 *  @param numberOfTests The total number of times the property was tested.
 *  @param result The result of the property test run. The result will obviously indicate 
 *                that the run has succeeded, but it also contains information on other
 *                aspects of the run, such as the seed used.
 */
- (void)runnerDidPassNumberOfTests:(NSUInteger)testNumber
                        withResult:(FOXRunnerResult *)result;

/*! A message sent to indicate that the runner has completed its run.
 *
 *  @param result The result of the run, which includes information on whether the run
 *                passed or failed.
 */
- (void)runnerDidRunWithResult:(FOXRunnerResult *)result;

@end

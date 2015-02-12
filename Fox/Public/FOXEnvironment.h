#import "FOXMacros.h"

/*! The default number of tests (which is 500).
 *
 *  Can be overridden by FOX_NUM_TESTS environment variables or by
 *  FOXSetNumberOfTests(). The environment variable superseeds the setter.
 *
 *  The setter is provided since iOS test bundles cannot be given environment
 *  variables via the xcodebuild test command.
 *
 *  @seealso FOXSetNumberOfTests to use the setter.
 *  @returns the number of tests the default runner should create.
 */
FOX_EXPORT NSUInteger FOXGetNumberOfTests(void);

/*! The default maximum size of data generation for tests (default 200).
 *
 *  Can be overridden by FOX_MAX_SIZE environment variable or by
 *  FOXSetMaximumSize(). The environment variable superseeds the setter.
 *
 *  The maximum size factor that generators will generate. A size value is generated
 *  by FOX as the size the generators in the properties use. The maximum size factor
 *  indicates a broader range of data values at the potential cost of computation.
 *
 *  Two examples: generating integers and arrays. The maximum size value indicates the
 *  minimum and maximum values the FOXInteger() generator can create. For array generation,
 *  the size indicates how large each element is (eg - large integers) AND how many
 *  elements are generated.
 *
 *  The setter is provided since iOS test bundles cannot be given environment
 *  variables via the xcodebuild test command.
 *
 *  @seealso FOXSetMaximumSize
 *  @returns the maximum size the default runner can generate for data in tests.
 */
FOX_EXPORT NSUInteger FOXGetMaximumSize(void);

/*! The default seed Fox uses to create data and run tests.
 *
 *  Can be overridden by FOX_SEED environment variable or by FOXSetSeed. The
 *  environment variable superseeds the setter.
 *
 *  The default will be the current time (using time(NULL)).
 *
 *  The setter is provided since iOS test bundles cannot be given environment
 *  variables via the xcodebuild test command.
 *
 *  @returns the random seed the default runner will use.
 */
FOX_EXPORT NSUInteger FOXGetSeed(void);

/*! Sets the default number of tests to use.
 *
 *  Does not override setting the FOX_NUM_TESTS environment variable.
 *
 *  @param defaultNumberOfTests The number of tests to generate by default.
 *  @seealso FOXGetNumberOfTests
 */
FOX_EXPORT void FOXSetNumberOfTests(NSUInteger defaultNumberOfTests);

/*! Sets the default maximum size to use.
 *
 *  Does not override setting the FOX_MAX_SIZE environment variable.
 *
 *  @param defaultMaximumSize The maximum size hint Fox should use to generate data by default.
 *  @seealso FOXGetMaximumSize
 */
FOX_EXPORT void FOXSetMaximumSize(NSUInteger defaultMaximumSize);

/*! Sets the default random seed to use.
 *
 *  Does not override setting the FOX_SEED environment variable.
 *
 *  @param defaultRandomSeed The random seed to use when generating data by default.
 *  @seealso FOXGetSeed
 */
FOX_EXPORT void FOXSetSeed(NSUInteger defaultRandomSeed);

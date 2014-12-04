#import "FOXMacros.h"

/*! The default number of tests (which is 500).
 *  Can be overridden by FOX_NUM_TESTS environment variables.
 *
 *  @returns the number of tests the default runner should create.
 */
FOX_EXPORT NSUInteger FOXGetNumberOfTests(void);

/*! The default maximum size of data generation for tests (default 200).
 *  Can be overridden by FOX_MAX_SIZE environment variable.
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
 *  @returns the maximum size the default runner can generate for data in tests.
 */
FOX_EXPORT NSUInteger FOXGetMaximumSize(void);

/*! The default seed Fox uses to create data and run tests.
 *  Can be overridden by FOX_SEED environment variable.
 *
 *  The default will be the current time (using time(NULL)).
 *
 *  @returns the random seed the default runner will use.
 */
FOX_EXPORT NSUInteger FOXGetSeed(void);

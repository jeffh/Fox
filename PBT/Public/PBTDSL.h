#import "PBTMacros.h"

@protocol PBTGenerator;
@class PBTRunnerResult;

/*! A set of options used to configure the behavior of PBTAssert.
 */
typedef struct {
    /*! The seed used when generated random data.
     *  The same seed will produce the same data.
     *  Set this to 0 (the default value) to generate a random seed.
     */
    uint32_t seed;

    /*! The number of times PBTAssert will generate random data and test the property.
     *  A value of 0 (the default) will cause PBTAssert to test the property 500 times.
     */
    NSUInteger numberOfTests;
} PBTOptions;

/*! Tests the given property. If the property does not hold, raises an exception that,
 *  within the context of an XCTest run, is surfaced as a test failure.
 *
 *  @param property The property to be tested.
 *  @param expr A string surfaced in the test failure to indicate which property was being tested.
 *  @param file The absolute path to the file in which the assertion is taking place.
 *  @param line The line on which the assertion is taking place.
 *  @param options A set of options used to configure the behavior of the assert.
 *  @returns The result of the property tests.
 */
PBT_EXPORT PBTRunnerResult *_PBTAssert(id<PBTGenerator> property, NSString *expr, const char * file, int line, PBTOptions options);

#define PBTAssertWithOptions(PROPERTY, OPTIONS) (_PBTAssert((PROPERTY), @"" # PROPERTY, __FILE__, __LINE__, (OPTIONS)))

#define PBTAssert(PROPERTY) (PBTAssertWithOptions(PROPERTY, (PBTOptions){}))

#if !defined(PBT_DISABLE_SHORTHAND) && !defined(PBT_DISABLE_SHORTHAND_ASSERT)
    #define Assert PBTAssert
    #define AssertWithOptions PBTAssertWithOptions
#endif

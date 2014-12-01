#import <Foundation/Foundation.h>


/*! The status of an individual property test result. */
typedef NS_ENUM(NSInteger, FOXPropertyStatus) {
    /*! The test failed. */
    FOXPropertyStatusFailed = 0,
    /*! The test passed. */
    FOXPropertyStatusPassed = 1,
    /*! The test was skipped. */
    FOXPropertyStatusSkipped = -1,
    /*! The test encountered an unexpected exception during execution. */
    FOXPropertyStatusUncaughtException = -2,
};

/*! Returns a property status based on a boolean condition.
 *
 *  @param assertion A boolean condition to test.
 *  @returns A passing status if the boolean condition evaluates to true, otherwise a failing status.
 */
FOUNDATION_STATIC_INLINE FOXPropertyStatus FOXRequire(BOOL assertion) {
    return assertion ? FOXPropertyStatusPassed : FOXPropertyStatusFailed;
}

/*! The result of an individual test of a property, with a single set of randomly generated values. */
@interface FOXPropertyResult : NSObject

/*! The value used to test the property. */
@property (nonatomic) id generatedValue;
/*! The exception that was caught during execution of the test. This is nil if no exception was encountered. */
@property (nonatomic) NSException *uncaughtException;
/*! The status of the result. */
@property (nonatomic) FOXPropertyStatus status;

/*! A boolean indicating whether the test has either failed, or terminated prematurely due to
 *  an uncaught exception.
 */
- (BOOL)hasFailedOrRaisedException;

@end


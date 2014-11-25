#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, FOXPropertyStatus) {
    FOXPropertyStatusFailed = 0,
    FOXPropertyStatusPassed = 1,
    FOXPropertyStatusSkipped = -1,
    FOXPropertyStatusUncaughtException = -2,
};

FOUNDATION_STATIC_INLINE FOXPropertyStatus FOXRequire(BOOL assertion) {
    return assertion ? FOXPropertyStatusPassed : FOXPropertyStatusFailed;
}

@interface FOXPropertyResult : NSObject

@property (nonatomic) id generatedValue;
@property (nonatomic) NSException *uncaughtException;
@property (nonatomic) FOXPropertyStatus status;

- (BOOL)hasFailedOrRaisedException;

@end


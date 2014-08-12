#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, PBTPropertyStatus) {
    PBTPropertyStatusFailed = 0,
    PBTPropertyStatusPassed = 1,
    PBTPropertyStatusSkipped = -1,
    PBTPropertyStatusUncaughtException = -2,
};

FOUNDATION_STATIC_INLINE PBTPropertyStatus PBTRequire(BOOL assertion) {
    return assertion ? PBTPropertyStatusPassed : PBTPropertyStatusFailed;
}

@interface PBTPropertyResult : NSObject

@property (nonatomic) id generatedValue;
@property (nonatomic) NSException *uncaughtException;
@property (nonatomic) PBTPropertyStatus status;

- (BOOL)hasFailedOrRaisedException;

@end


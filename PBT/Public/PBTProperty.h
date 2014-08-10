#import "PBTGenerator.h"


typedef NS_ENUM(NSInteger, PBTPropertyStatus) {
    PBTPropertyStatusFailed = 0,
    PBTPropertyStatusPassed = 1,
    PBTPropertyStatusSkipped = -1,
    PBTPropertyStatusUncaughtException = -2,
};

@interface PBTProperty : NSObject

+ (id<PBTGenerator>)forAll:(id<PBTGenerator>)generator
                      then:(PBTPropertyStatus (^)(id generatedValue))then;

@end

@interface PBTPropertyResult : NSObject

@property (nonatomic) id generatedValue;
@property (nonatomic) NSException *uncaughtException;
@property (nonatomic) PBTPropertyStatus status;

- (BOOL)hasFailedOrRaisedException;

@end


FOUNDATION_STATIC_INLINE PBTPropertyStatus PBTRequire(BOOL assertion)
{
    return assertion ? PBTPropertyStatusPassed : PBTPropertyStatusFailed;
}

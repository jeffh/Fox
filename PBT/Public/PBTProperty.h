#import <Foundation/Foundation.h>
#import "PBTGenerator.h"


typedef NS_ENUM(NSUInteger, PBTPropertyStatus) {
    PBTPropertyStatusSkipped,
    PBTPropertyStatusFailed,
    PBTPropertyStatusPassed,
    PBTPropertyStatusUncaughtException,
};

@interface PBTProperty : NSObject

+ (PBTGenerator)forAll:(PBTGenerator)generator
                  then:(PBTPropertyStatus (^)(id generatedValue))then;

@end

@interface PBTPropertyResult : NSObject

@property (nonatomic) id generatedValue;
@property (nonatomic) PBTPropertyStatus status;

@end


FOUNDATION_STATIC_INLINE PBTPropertyStatus PBTRequire(BOOL assertion)
{
    return assertion ? PBTPropertyStatusPassed : PBTPropertyStatusFailed;
}

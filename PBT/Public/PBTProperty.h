#import <Foundation/Foundation.h>
#import "PBTGenerator.h"


typedef NS_ENUM(NSUInteger, PBTPropertyResult) {
    PBTPropertyResultSkipped,
    PBTPropertyResultFailed,
    PBTPropertyResultPassed,
};

@interface PBTProperty : NSObject

+ (id)forAll:(PBTGenerator)generator
        then:(PBTPropertyResult (^)(id generatedValue))then;

@end


FOUNDATION_STATIC_INLINE PBTPropertyResult PBTRequire(BOOL assertion)
{
    return assertion ? PBTPropertyResultPassed : PBTPropertyResultFailed;
}

#import <Foundation/Foundation.h>
#import "PBTGenerator.h"


typedef NS_ENUM(NSUInteger, PBTPropertyResult) {
    PBTPropertyResultFailed,
    PBTPropertyResultPassed,
    PBTPropertyResultSkipped,
};

@interface PBTProperty : NSObject

+ (id)forAll:(PBTGenerator)generator
        then:(PBTPropertyResult (^)(id generatedValue))then;

@end


FOUNDATION_STATIC_INLINE PBTPropertyResult PBTRequire(BOOL assertion)
{
    return assertion ? PBTPropertyResultPassed : PBTPropertyResultFailed;
}

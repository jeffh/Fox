#import <Foundation/Foundation.h>
#import "PBTGenerator.h"
#import "PBTProperty.h"


@class PBTQuickCheckResult;


@interface PBTQuickCheck : NSObject

- (PBTQuickCheckResult *)checkWithNumberOfTests:(NSUInteger)numberOfTests
                                       property:(id<PBTGenerator>)property;
- (PBTQuickCheckResult *)checkWithNumberOfTests:(NSUInteger)numberOfTests
                                  forAll:(id<PBTGenerator>)values
                                    then:(PBTPropertyStatus (^)(id generatedValue))then;


@end

#import "FOXGenerator.h"


@class FOXRoseTree;


@interface FOXPureGenerator : NSObject <FOXGenerator>

- (instancetype)initWithRoseTree:(FOXRoseTree *)roseTree;

@end

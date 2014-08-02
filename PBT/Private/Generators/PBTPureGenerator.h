#import "PBTGenerator.h"


@class PBTRoseTree;


@interface PBTPureGenerator : NSObject <PBTGenerator>

- (instancetype)initWithRoseTree:(PBTRoseTree *)roseTree;

@end

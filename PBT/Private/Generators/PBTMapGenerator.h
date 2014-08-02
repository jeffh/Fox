#import "PBTGenerator.h"

@interface PBTMapGenerator : NSObject <PBTGenerator>

- (instancetype)initWithGenerator:(id<PBTGenerator>)generator
                              map:(PBTRoseTree *(^)(PBTRoseTree *generatedTree))map;

@end

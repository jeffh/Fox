#import "FOXGenerator.h"

@interface FOXMapGenerator : NSObject <FOXGenerator>

- (instancetype)initWithGenerator:(id<FOXGenerator>)generator
                              map:(FOXRoseTree *(^)(FOXRoseTree *generatedTree))map;

@end

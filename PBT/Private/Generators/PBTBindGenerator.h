#import "PBTGenerator.h"


@interface PBTBindGenerator : NSObject <PBTGenerator>

- (instancetype)initWithGenerator:(id<PBTGenerator>)generator
                          factory:(id<PBTGenerator>(^)(PBTRoseTree *generatedTree))factory;

@end

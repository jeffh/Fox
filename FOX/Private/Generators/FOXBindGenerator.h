#import "FOXGenerator.h"


@interface FOXBindGenerator : NSObject <FOXGenerator>

- (instancetype)initWithGenerator:(id<FOXGenerator>)generator
                          factory:(id<FOXGenerator>(^)(FOXRoseTree *generatedTree))factory;

@end

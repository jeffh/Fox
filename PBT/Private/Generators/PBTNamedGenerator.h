#import "PBTGenerator.h"


@interface PBTNamedGenerator : NSObject <PBTGenerator>

- (instancetype)initWithName:(NSString *)name forGenerator:(id<PBTGenerator>)generator;

@end

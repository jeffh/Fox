#import "FOXGenerator.h"


@interface FOXNamedGenerator : NSObject <FOXGenerator>

- (instancetype)initWithName:(NSString *)name forGenerator:(id<FOXGenerator>)generator;

@end

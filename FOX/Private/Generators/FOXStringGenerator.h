#import "FOXGenerator.h"


@interface FOXStringGenerator : NSObject <FOXGenerator>

- (instancetype)initWithArrayOfIntegersGenerator:(id<FOXGenerator>)generator name:(NSString *)name;

@end

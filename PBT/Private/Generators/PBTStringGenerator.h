#import "PBTGenerator.h"


@interface PBTStringGenerator : NSObject <PBTGenerator>

- (instancetype)initWithArrayOfIntegersGenerator:(id<PBTGenerator>)generator name:(NSString *)name;

@end

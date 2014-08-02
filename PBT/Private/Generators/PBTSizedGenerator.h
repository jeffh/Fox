#import "PBTGenerator.h"


@interface PBTSizedGenerator : NSObject <PBTGenerator>

- (instancetype)initWithFactory:(id<PBTGenerator> (^)(NSUInteger size))factory;

@end

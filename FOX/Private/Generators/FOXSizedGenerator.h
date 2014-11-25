#import "FOXGenerator.h"


@interface FOXSizedGenerator : NSObject <FOXGenerator>

- (instancetype)initWithFactory:(id<FOXGenerator> (^)(NSUInteger size))factory;

@end

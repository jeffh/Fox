#import <Foundation/Foundation.h>
#import "FOXGenerator.h"


@interface FOXBlockGenerator : NSObject <FOXGenerator>

- (instancetype)initWithBlock:(FOXRoseTree *(^)(id<FOXRandom>, NSUInteger))block;

@end

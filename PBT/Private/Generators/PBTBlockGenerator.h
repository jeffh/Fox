#import <Foundation/Foundation.h>
#import "PBTGenerator.h"


@interface PBTBlockGenerator : NSObject <PBTGenerator>

- (instancetype)initWithBlock:(PBTRoseTree *(^)(id<PBTRandom>, NSUInteger))block;

@end

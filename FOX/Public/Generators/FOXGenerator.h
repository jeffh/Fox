#import <Foundation/Foundation.h>


@protocol FOXRandom;
@class FOXRoseTree;


@protocol FOXGenerator<NSObject>

- (FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize;

@end


#import <Foundation/Foundation.h>


@protocol PBTRandom;
@class PBTRoseTree;


@protocol PBTGenerator <NSObject>

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize;

@end


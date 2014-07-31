#import <Foundation/Foundation.h>


@interface PBTQuickCheckResult : NSObject

@property (nonatomic) BOOL succeeded;
@property (nonatomic) NSUInteger maxSize;
@property (nonatomic) NSUInteger numberOfTests;
@property (nonatomic) uint32_t seed;

// only filled when failures occur (succeeded = NO)
@property (nonatomic) NSUInteger failingSize;
@property (nonatomic) id failingArguments;
@property (nonatomic) NSUInteger shrinkDepth;
@property (nonatomic) NSUInteger shrinkNodeWalkCount;
@property (nonatomic) id smallestFailingArguments;

- (NSString *)friendlyDescription;

@end

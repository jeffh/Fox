#import "PBTBlockGenerator.h"


@interface PBTBlockGenerator ()

@property (nonatomic, copy) PBTRoseTree *(^block)(id<PBTRandom>, NSUInteger);

@end


@implementation PBTBlockGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithBlock:(PBTRoseTree *(^)(id<PBTRandom>, NSUInteger))block
{
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize
{
    return self.block(random, maximumSize);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PBTBlockGenerator: %p>", self];
}

@end

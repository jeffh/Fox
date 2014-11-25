#import "FOXBlockGenerator.h"


@interface FOXBlockGenerator ()

@property (nonatomic, copy) FOXRoseTree *(^block)(id<FOXRandom>, NSUInteger);

@end


@implementation FOXBlockGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithBlock:(FOXRoseTree *(^)(id<FOXRandom>, NSUInteger))block
{
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

- (FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize
{
    return self.block(random, maximumSize);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FOXBlockGenerator: %p>", self];
}

@end

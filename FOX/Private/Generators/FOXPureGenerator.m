#import "FOXPureGenerator.h"


@interface FOXPureGenerator ()
@property (nonatomic) FOXRoseTree *roseTree;
@property (nonatomic) NSString *name;
@end


@implementation FOXPureGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithRoseTree:(FOXRoseTree *)roseTree
{
    self = [super init];
    if (self) {
        self.roseTree = roseTree;
        self.name = @"FOXPureGenerator";
    }
    return self;
}

-(FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize
{
    return self.roseTree;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FOXPureGenerator: %p(roseTree=%p)>", self, self.roseTree];
}

@end

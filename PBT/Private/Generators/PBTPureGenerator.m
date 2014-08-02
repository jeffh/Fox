#import "PBTPureGenerator.h"


@interface PBTPureGenerator ()
@property (nonatomic) PBTRoseTree *roseTree;
@property (nonatomic) NSString *name;
@end


@implementation PBTPureGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithRoseTree:(PBTRoseTree *)roseTree
{
    self = [super init];
    if (self) {
        self.roseTree = roseTree;
        self.name = @"PBTPureGenerator";
    }
    return self;
}

-(PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize
{
    return self.roseTree;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PBTPureGenerator: %p(roseTree=%p)>", self, self.roseTree];
}

@end

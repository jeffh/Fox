#import "PBTMapGenerator.h"


@interface PBTMapGenerator ()
@property (nonatomic) id<PBTGenerator> generator;
@property (nonatomic, copy) PBTRoseTree *(^mapper)(PBTRoseTree *);
@end


@implementation PBTMapGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithGenerator:(id<PBTGenerator>)generator
                              map:(PBTRoseTree *(^)(PBTRoseTree *generatedTree))map
{
    self = [super init];
    if (self) {
        self.generator = generator;
        self.mapper = map;
    }
    return self;
}

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize
{
    PBTRoseTree *generatedTree = [self.generator lazyTreeWithRandom:random maximumSize:maximumSize];
    return self.mapper(generatedTree);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PBTMapGenerator: %p (%@)>", self, self.generator];
}

@end

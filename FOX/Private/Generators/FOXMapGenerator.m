#import "FOXMapGenerator.h"


@interface FOXMapGenerator ()
@property (nonatomic) id<FOXGenerator> generator;
@property (nonatomic, copy) FOXRoseTree *(^mapper)(FOXRoseTree *);
@end


@implementation FOXMapGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithGenerator:(id<FOXGenerator>)generator
                              map:(FOXRoseTree *(^)(FOXRoseTree *generatedTree))map
{
    self = [super init];
    if (self) {
        self.generator = generator;
        self.mapper = map;
    }
    return self;
}

- (FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize
{
    FOXRoseTree *generatedTree = [self.generator lazyTreeWithRandom:random maximumSize:maximumSize];
    return self.mapper(generatedTree);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FOXMapGenerator: %p (%@)>", self, self.generator];
}

@end

#import "FOXBindGenerator.h"


@interface FOXBindGenerator ()
@property (nonatomic) id<FOXGenerator> generator;
@property (nonatomic, copy) id<FOXGenerator> (^factory)(FOXRoseTree *);
@end


@implementation FOXBindGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithGenerator:(id<FOXGenerator>)generator
                          factory:(id<FOXGenerator>(^)(FOXRoseTree *generatedTree))factory
{
    self = [super init];
    if (self) {
        self.generator = generator;
        self.factory = factory;
    }
    return self;
}

- (FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize
{
    FOXRoseTree *innerTree = [self.generator lazyTreeWithRandom:random
                                                    maximumSize:maximumSize];
    id<FOXGenerator> resultingGenerator = self.factory(innerTree);
    return [resultingGenerator lazyTreeWithRandom:random
                                      maximumSize:maximumSize];

}

@end

#import "PBTBindGenerator.h"


@interface PBTBindGenerator ()
@property (nonatomic) id<PBTGenerator> generator;
@property (nonatomic, copy) id<PBTGenerator> (^factory)(PBTRoseTree *);
@end


@implementation PBTBindGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithGenerator:(id<PBTGenerator>)generator
                          factory:(id<PBTGenerator>(^)(PBTRoseTree *generatedTree))factory
{
    self = [super init];
    if (self) {
        self.generator = generator;
        self.factory = factory;
    }
    return self;
}

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize
{
    PBTRoseTree *innerTree = [self.generator lazyTreeWithRandom:random
                                                    maximumSize:maximumSize];
    id<PBTGenerator> resultingGenerator = self.factory(innerTree);
    return [resultingGenerator lazyTreeWithRandom:random
                                      maximumSize:maximumSize];

}

@end

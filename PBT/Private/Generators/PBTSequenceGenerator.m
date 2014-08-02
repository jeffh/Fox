#import "PBTSequenceGenerator.h"
#import "PBTRoseTree.h"


@interface PBTSequenceGenerator ()
@property (nonatomic) id<PBTSequence> generators;
@property (nonatomic, copy) PBTRoseTree *(^reducer)(id<PBTGenerator> accumGenerator, id<PBTGenerator> itemGenerator);
@property (nonatomic) id<PBTGenerator> joinedGenerator;
@end


@implementation PBTSequenceGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithGenerators:(id<PBTSequence>)generators
                           reducer:(PBTRoseTree *(^)(id<PBTGenerator> accumGenerator, id<PBTGenerator> itemGenerator))reducer
{
    self = [super init];
    if (self) {
        self.generators = generators;
        self.reducer = reducer;
    }
    return self;
}

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize
{
    return [self.joinedGenerator lazyTreeWithRandom:random maximumSize:maximumSize];
}

#pragma mark - Properties

- (id<PBTGenerator>)joinedGenerator
{
    if (!_joinedGenerator) {
        PBTRoseTree *emptyTree = [[PBTRoseTree alloc] initWithValue:@[]];
        _joinedGenerator = [self.generators objectByReducingWithSeed:PBTGenPure(emptyTree)
                                                             reducer:self.reducer];
    }
    return _joinedGenerator;
}

@end

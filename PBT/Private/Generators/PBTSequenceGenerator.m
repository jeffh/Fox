#import "PBTSequenceGenerator.h"
#import "PBTRoseTree.h"
#import "PBTCoreGenerators.h"


@interface PBTSequenceGenerator ()
@property (nonatomic) id<PBTSequence> generators;
@property (nonatomic) id<PBTGenerator> joinedGenerator;
@end


@implementation PBTSequenceGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithGenerators:(id<PBTSequence>)generators
{
    self = [super init];
    if (self) {
        self.generators = generators;
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
                                                             reducer:^id(id<PBTGenerator> accumGenerator, id<PBTGenerator> itemGenerator) {
            return PBTGenBind(accumGenerator, ^id<PBTGenerator>(PBTRoseTree *accumTree) {
                return PBTGenBind(itemGenerator, ^id<PBTGenerator>(PBTRoseTree *itemTree) {
                    return PBTReturn([accumTree.value arrayByAddingObject:itemTree]);
                });
            });
        }];
    }
    return _joinedGenerator;
}

@end

#import "FOXSequenceGenerator.h"
#import "FOXRoseTree.h"
#import "FOXCoreGenerators.h"


@interface FOXSequenceGenerator ()
@property (nonatomic) id<FOXSequence> generators;
@property (nonatomic) id<FOXGenerator> joinedGenerator;
@end


@implementation FOXSequenceGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithGenerators:(id<FOXSequence>)generators
{
    self = [super init];
    if (self) {
        self.generators = generators;
    }
    return self;
}

- (FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize
{
    return [self.joinedGenerator lazyTreeWithRandom:random maximumSize:maximumSize];
}

#pragma mark - Properties

- (id<FOXGenerator>)joinedGenerator
{
    if (!_joinedGenerator) {
        FOXRoseTree *emptyTree = [[FOXRoseTree alloc] initWithValue:@[]];
        _joinedGenerator = [self.generators objectByReducingWithSeed:FOXGenPure(emptyTree)
                                                             reducer:^id(id<FOXGenerator> accumGenerator, id<FOXGenerator> itemGenerator) {
            return FOXGenBind(accumGenerator, ^id<FOXGenerator>(FOXRoseTree *accumTree) {
                return FOXGenBind(itemGenerator, ^id<FOXGenerator>(FOXRoseTree *itemTree) {
                    return FOXReturn([accumTree.value arrayByAddingObject:itemTree]);
                });
            });
        }];
    }
    return _joinedGenerator;
}

@end

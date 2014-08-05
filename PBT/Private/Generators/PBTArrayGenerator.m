#import "PBTArrayGenerator.h"
#import "PBTSequenceGenerator.h"
#import "PBTRoseTree.h"


@interface PBTArrayGenerator ()
@property (nonatomic) id<PBTSequence> generators;
@property (nonatomic) id<PBTGenerator> sequenceGenerator;
@end


@implementation PBTArrayGenerator

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
    return [self.sequenceGenerator lazyTreeWithRandom:random maximumSize:maximumSize];
}

#pragma mark - Properties

- (id<PBTGenerator>)sequenceGenerator
{
    if (!_sequenceGenerator) {
        _sequenceGenerator = PBTGenBind([[PBTSequenceGenerator alloc] initWithGenerators:self.generators], ^id<PBTGenerator>(PBTRoseTree *generatorTree) {
            NSArray *roseTrees = generatorTree.value;
            return PBTGenPure([PBTRoseTree shrinkTreeFromRoseTrees:roseTrees merger:^id(NSArray *values) {
                return values;
            }]);
        });
    }
    return _sequenceGenerator;
}

@end

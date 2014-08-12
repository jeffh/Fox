#import "PBTTupleGenerator.h"
#import "PBTSequence.h"
#import "PBTSequenceGenerator.h"
#import "PBTRoseTree.h"
#include "PBTCoreGenerators.h"


@interface PBTTupleGenerator ()
@property (nonatomic) id<PBTSequence> generators;
@property (nonatomic) id<PBTGenerator> sequenceGenerator;
@end


@implementation PBTTupleGenerator

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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PBTTupleGenerator: %@>", self.generators];
}

#pragma mark - Properties

- (id<PBTGenerator>)sequenceGenerator
{
    if (!_sequenceGenerator) {
        _sequenceGenerator = PBTGenBind([[PBTSequenceGenerator alloc] initWithGenerators:self.generators], ^id<PBTGenerator>(PBTRoseTree *generatorTree) {
            NSArray *roseTrees = generatorTree.value;
            return PBTGenPure([PBTRoseTree zipTreeFromRoseTrees:roseTrees]);
        });
    }
    return _sequenceGenerator;
}

@end

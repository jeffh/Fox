#import "PBTTupleGenerator.h"
#import "PBTSequence.h"
#import "PBTSequenceGenerator.h"
#import "PBTRoseTree.h"


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
        _sequenceGenerator = [[PBTSequenceGenerator alloc] initWithGenerators:self.generators reducer:^PBTRoseTree *(id<PBTGenerator> accumGenerator, id<PBTGenerator> itemGenerator) {
            return PBTGenPure([PBTRoseTree zipTreeFromRoseTrees:@[accumGenerator, itemGenerator] byApplying:^id(NSArray *values) {
                return values;
            }]);
        }];
    }
    return _sequenceGenerator;
}

@end

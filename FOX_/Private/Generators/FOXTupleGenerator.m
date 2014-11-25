#import "FOXTupleGenerator.h"
#import "FOXSequence.h"
#import "FOXSequenceGenerator.h"
#import "FOXRoseTree.h"
#import "FOXCoreGenerators.h"


@interface FOXTupleGenerator ()
@property (nonatomic) id<FOXSequence> generators;
@property (nonatomic) id<FOXGenerator> sequenceGenerator;
@end


@implementation FOXTupleGenerator

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
    return [self.sequenceGenerator lazyTreeWithRandom:random maximumSize:maximumSize];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FOXTupleGenerator: %@>", self.generators];
}

#pragma mark - Properties

- (id<FOXGenerator>)sequenceGenerator
{
    if (!_sequenceGenerator) {
        _sequenceGenerator = FOXGenBind([[FOXSequenceGenerator alloc] initWithGenerators:self.generators], ^id<FOXGenerator>(FOXRoseTree *generatorTree) {
            NSArray *roseTrees = generatorTree.value;
            return FOXGenPure([FOXRoseTree zipTreeFromRoseTrees:roseTrees]);
        });
    }
    return _sequenceGenerator;
}

@end

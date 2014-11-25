#import "FOXArrayGenerator.h"
#import "FOXSequenceGenerator.h"
#import "FOXRoseTree.h"
#import "FOXCoreGenerators.h"
#import "FOXSequence.h"


@interface FOXArrayGenerator ()
@property (nonatomic) id<FOXSequence> generators;
@property (nonatomic) id<FOXGenerator> sequenceGenerator;
@end


@implementation FOXArrayGenerator

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
    return [self.sequenceGenerator lazyTreeWithRandom:random maximumSize:maximumSize];
}

#pragma mark - Properties

- (id<FOXGenerator>)sequenceGenerator
{
    if (!_sequenceGenerator) {
        _sequenceGenerator = FOXGenBind([[FOXSequenceGenerator alloc] initWithGenerators:self.generators], ^id<FOXGenerator>(FOXRoseTree *generatorTree) {
            NSArray *roseTrees = generatorTree.value;
            return FOXGenPure([FOXRoseTree shrinkTreeFromRoseTrees:roseTrees]);
        });
    }
    return _sequenceGenerator;
}

@end

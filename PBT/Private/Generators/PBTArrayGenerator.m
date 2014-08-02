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
        _sequenceGenerator = [[PBTSequenceGenerator alloc] initWithGenerators:self.generators reducer:^id(id<PBTGenerator> accumGenerator, id<PBTGenerator> generator) {
            return PBTGenBind(accumGenerator, ^id<PBTGenerator>(PBTRoseTree *generatorTree) {
                return PBTGenBind(generator, ^id<PBTGenerator>(PBTRoseTree *itemTree) {
                    return PBTGenPure([self roseTreeFromAccumulatorTree:generatorTree itemRoseTree:itemTree]);
                });
            });
        }];
    }
    return _sequenceGenerator;
}

#pragma mark - Private

- (PBTRoseTree *)roseTreeFromAccumulatorTree:(PBTRoseTree *)accumulatorTree itemRoseTree:(PBTRoseTree *)itemTree
{
    return [PBTRoseTree mergedTreeFromRoseTrees:@[accumulatorTree, itemTree]
                                      emptyTree:[[PBTRoseTree alloc] initWithValue:@[]]
                                         merger:^id(NSArray *values)
            {
                NSArray *accumValues = values[0];
                id generatorValue = values[1];
                return [accumValues arrayByAddingObject:generatorValue];
            }];
}

@end

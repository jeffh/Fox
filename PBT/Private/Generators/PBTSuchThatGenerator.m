#import "PBTSuchThatGenerator.h"
#import "PBTRoseTree.h"


@interface PBTSuchThatGenerator ()
@property (nonatomic) id<PBTGenerator> generator;
@property (nonatomic, copy) BOOL (^predicate)(id generatedValue);
@property (nonatomic) NSUInteger maxTries;
@end


@implementation PBTSuchThatGenerator

- (instancetype)initWithGenerator:(id<PBTGenerator>)generator predicate:(BOOL(^)(id generatedValue))predicate maxTries:(NSUInteger)maxTries
{
    self = [super init];
    if (self) {
        self.generator = generator;
        self.predicate = predicate;
        self.maxTries = maxTries;
    }
    return self;
}

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize
{
    NSUInteger attempts = 0;

    while (attempts < self.maxTries) {
        PBTRoseTree *tree = [self.generator lazyTreeWithRandom:random maximumSize:maximumSize + attempts];
        if (self.predicate(tree.value)) {
            return [tree treeFilterChildrenByBlock:self.predicate];
        }
    }

    [NSException raise:@"PBTGenerationFailed"
                format:@"PBTSuchThat generator could failed to satisfy predicate after %lu times", self.maxTries];
    return nil;
}

@end

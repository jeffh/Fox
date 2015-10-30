#import "FOXSuchThatGenerator.h"
#import "FOXRoseTree.h"


@interface FOXSuchThatGenerator ()
@property (nonatomic) id<FOXGenerator> generator;
@property (nonatomic, copy) BOOL (^predicate)(id generatedValue);
@property (nonatomic) NSUInteger maxTries;
@end


@implementation FOXSuchThatGenerator

- (instancetype)initWithGenerator:(id<FOXGenerator>)generator predicate:(BOOL(^)(id generatedValue))predicate maxTries:(NSUInteger)maxTries
{
    self = [super init];
    if (self) {
        self.generator = generator;
        self.predicate = predicate;
        self.maxTries = maxTries;
    }
    return self;
}

- (FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize
{

    for(NSUInteger attempts = 0; attempts < self.maxTries; attempts++) {
        FOXRoseTree *tree = [self.generator lazyTreeWithRandom:random maximumSize:maximumSize + attempts];
        if (self.predicate(tree.value)) {
            return [tree treeFilterChildrenByBlock:self.predicate];
        }
    }


    [NSException raise:@"FOXGenerationFailed"
                format:@"FOXSuchThat generator could failed to satisfy predicate after %lu times",
                       (unsigned long)self.maxTries];
    return nil;
}

@end

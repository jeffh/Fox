#import "PBTRoseTree.h"
#import "PBTSequence.h"

#import <objc/message.h>

@implementation PBTRoseTree

+ (instancetype)treeFromArray:(NSArray *)roseTreeLiteral
{
    NSParameterAssert(roseTreeLiteral.count == 2);
    NSMutableArray *subtrees = [NSMutableArray arrayWithCapacity:roseTreeLiteral.count];
    for (id subtree in roseTreeLiteral[1]) {
        [subtrees addObject:[self treeFromArray:subtree]];
    }
    return [[PBTRoseTree alloc] initWithValue:[roseTreeLiteral firstObject]
                                     children:[PBTSequence sequenceFromArray:subtrees]];
}

+ (instancetype)mergedTreeFromRoseTrees:(NSArray *)roseTrees merger:(id(^)(NSArray *values))merger
{
    if (!roseTrees.count) {
        return [[PBTRoseTree alloc] initWithValue:merger(nil)];
    }
    id<PBTSequence> rootChildren = [PBTSequence lazySequenceFromBlock:^id<PBTSequence>{
        id<PBTSequence> sequence = [PBTSequence sequenceFromArray:roseTrees];

        id<PBTSequence> oneLessTreeSequence = [sequence sequenceByApplyingIndexedBlock:^id(NSUInteger index, PBTRoseTree *_roseTree) {
            return [sequence sequenceByExcludingIndex:index];
        }];

        id<PBTSequence> permutationSequence = ({
            NSArray *base = [[sequence objectEnumerator] allObjects];
            NSMutableArray *permutations = [NSMutableArray array];
            NSUInteger i = 0;
            for (PBTRoseTree *roseTree in sequence) {
                for (id<PBTSequence> child in roseTree.children) {
                    NSMutableArray *permutation = [base mutableCopy];
                    permutation[i] = child;
                    [permutations addObject:permutation];
                }
                i++;
            }
            [PBTSequence sequenceFromArray:permutations];
        });

        id<PBTSequence> removalTree = [oneLessTreeSequence sequenceByConcatenatingSequence:permutationSequence];

        return [removalTree sequenceByApplyingBlock:^id(id trees) {
            return [self mergedTreeFromRoseTrees:[[trees objectEnumerator] allObjects] merger:merger];
        }];
    }];
    id value = merger([roseTrees valueForKey:@"value"]);
    return [[PBTRoseTree alloc] initWithValue:value
                                     children:rootChildren];
}


- (instancetype)initWithValue:(id)value
{
    return [self initWithValue:value children:nil];
}

- (instancetype)initWithValue:(id)value children:(id<PBTSequence>)children
{
    self = [self init];
    if (self) {
        self.value = value;
        self.children = children;
    }
    return self;
}

- (PBTRoseTree *)treeByApplyingBlock:(id(^)(id element))block
{
    return [[PBTRoseTree alloc] initWithValue:block(self.value)
                                     children:[self.children sequenceByApplyingBlock:^id(PBTRoseTree *subtree) {
        return [subtree treeByApplyingBlock:block];
    }]];
}

- (PBTRoseTree *)treeFilteredByBlock:(BOOL(^)(id element))block
{
    return [[PBTRoseTree alloc] initWithValue:self.value
                                     children:[[self.children sequenceFilteredByBlock:^BOOL(PBTRoseTree *subtree) {
        return block(subtree.value);
    }] sequenceByApplyingBlock:^id(PBTRoseTree *subtree) {
        return [subtree treeFilteredByBlock:block];
    }]];
}

- (NSArray *)array
{
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:self.value];

    NSArray *children = [[[self.children sequenceByApplyingBlock:^id(PBTRoseTree *subtree) {
        return [subtree array];
    }] objectEnumerator] allObjects];
    [items addObject:[NSArray arrayWithObjects:children, nil]];
    
    return items;
}

#pragma mark - Property Overrides

- (id<PBTSequence>)children
{
    if (!_children) {
        _children = [PBTSequence sequence];
    }
    return _children;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    PBTRoseTree *other = object;

    return (self.value == other.value || [self.value isEqual:other.value])
        && (self.children == other.children || [self.children isEqual:other.children]);
}

- (NSUInteger)hash
{
    return 31 * [self.value hash] + 31 * [self.children hash];
}

- (NSString *)description
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@: ",
                               NSStringFromClass([self class])];
    [string appendString:[self.value description] ?: @"nil"];

    if ([self.children firstObject]) {
        [string appendString:@",\n  "];
        NSArray *lines = [[self.children description] componentsSeparatedByString:@"\n"];
        [string appendString:[lines componentsJoinedByString:@"\n  "]];
    }

    [string appendString:@">"];
    return string;
}

@end

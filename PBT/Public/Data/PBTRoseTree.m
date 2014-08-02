#import "PBTRoseTree.h"
#import "PBTSequence.h"


@implementation PBTRoseTree

+ (id<PBTSequence>)permutationsOfRoseTrees:(NSArray *)roseTrees
{
    NSMutableArray *permutations = [NSMutableArray array];
    NSUInteger index = 0;
    for (PBTRoseTree *roseTree in roseTrees) {
        for (id<PBTSequence> child in roseTree.children) {
            NSMutableArray *permutation = [roseTrees mutableCopy];
            permutation[index] = child;
            [permutations addObject:permutation];
        }
        ++index;
    }
    return [PBTSequence sequenceFromArray:permutations];
}

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

+ (instancetype)mergedTreeFromRoseTrees:(NSArray *)roseTrees emptyTree:(PBTRoseTree *)emptyTree merger:(id(^)(NSArray *values))merger
{
    if (!roseTrees.count) {
        return emptyTree;
    }
    NSAssert([roseTrees count] > 1, @"Need at least 2 rose trees to merge");

    id<PBTSequence> rootChildren = [PBTSequence lazySequenceFromBlock:^id<PBTSequence>{
        id<PBTSequence> sequence = [PBTSequence sequenceFromArray:roseTrees];

        id<PBTSequence> oneLessTreeSequence = [sequence sequenceByApplyingIndexedBlock:^id(NSUInteger index, PBTRoseTree *_roseTree) {
            return [[[sequence sequenceByExcludingIndex:index] objectEnumerator] allObjects];
        }];
        id<PBTSequence> permutationSequence = [self permutationsOfRoseTrees:roseTrees];

        id<PBTSequence> alternativeTrees = [oneLessTreeSequence sequenceByConcatenatingSequence:permutationSequence];
        // TODO: Figure out why we can't/should merge one-tree sequences
        alternativeTrees = [alternativeTrees sequenceFilteredByBlock:^BOOL(id item) {
            return [item count] > 1;
        }];

        return [alternativeTrees sequenceByApplyingBlock:^id(id trees) {
            if (0){
                NSLog(@"================> %@ %@ %@ %@", alternativeTrees, oneLessTreeSequence, permutationSequence, roseTrees);
            }
            return [self mergedTreeFromRoseTrees:[[trees objectEnumerator] allObjects] emptyTree:emptyTree merger:merger];
        }];
    }];
    id value = merger([roseTrees valueForKey:@"value"]);
    return [[PBTRoseTree alloc] initWithValue:value
                                     children:rootChildren];
}

+ (instancetype)zipTreeFromRoseTrees:(NSArray *)roseTrees byApplying:(id(^)(NSArray *values))block
{
    return [[PBTRoseTree alloc] initWithValue:block([roseTrees valueForKey:@"value"])
                                     children:[[self permutationsOfRoseTrees:roseTrees] sequenceByApplyingBlock:^id(NSArray *subtrees) {
        return [self zipTreeFromRoseTrees:subtrees byApplying:block];
    }]];
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

- (PBTRoseTree *)treeFilterChildrenByBlock:(BOOL(^)(id element))block
{
    return [[PBTRoseTree alloc] initWithValue:self.value
                                     children:[[self.children sequenceFilteredByBlock:^BOOL(PBTRoseTree *subtree) {
        return block(subtree.value);
    }] sequenceByApplyingBlock:^id(PBTRoseTree *subtree) {
        return [subtree treeFilterChildrenByBlock:block];
    }]];
}

- (PBTRoseTree *)treeFilterByBlock:(BOOL(^)(id element))block
{
    if (block(self.value)) {
        return [self treeFilterChildrenByBlock:block];
    } else {
        for (PBTRoseTree *subtree in self.children) {
            if (block(subtree.value)) {
                return [subtree treeFilterChildrenByBlock:block];
            }
        }
        return [[PBTRoseTree alloc] initWithValue:nil];
    }
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
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@: %p ",
                               NSStringFromClass([self class]), self];
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

#import "PBTRoseTree.h"
#import "PBTSequence.h"

#ifdef DEBUG
@interface PBTRoseTree ()
@property (nonatomic, weak) id parent;
@property (nonatomic) NSArray *createdCallStack;
@end
#endif


@implementation PBTRoseTree

+ (id<PBTSequence>)permutationsOfRoseTrees:(NSArray *)roseTrees
{
    NSMutableArray *permutations = [NSMutableArray array];
    NSUInteger index = 0;
    for (PBTRoseTree *roseTree in roseTrees) {
        for (PBTRoseTree *child in roseTree.children) {
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
    NSAssert(roseTreeLiteral.count == 2, @"roseTreeLiteral.count == 2, got: %@ (count=%lu)", roseTreeLiteral, (unsigned long)roseTreeLiteral.count);
    NSMutableArray *subtrees = [NSMutableArray arrayWithCapacity:roseTreeLiteral.count];
    for (id subtree in roseTreeLiteral[1]) {
        [subtrees addObject:[self treeFromArray:subtree]];
    }
    return [[PBTRoseTree alloc] initWithValue:[roseTreeLiteral firstObject]
                                     children:[PBTSequence sequenceFromArray:subtrees]];
}

+ (instancetype)joinedTreeFromNestedRoseTree:(PBTRoseTree *)roseTree
{
    PBTRoseTree *rootTree = roseTree.value;
    id<PBTSequence> children = [rootTree.children sequenceByApplyingBlock:^id(PBTRoseTree *tree) {
        return [self joinedTreeFromNestedRoseTree:tree];
    }];
    children = [children sequenceByConcatenatingSequence:roseTree.children];
    return [[PBTRoseTree alloc] initWithValue:rootTree.value
                                     children:children];
}

+ (id<PBTSequence>)sequenceByExpandingRoseTrees:(NSArray *)roseTrees
{
    return [PBTSequence lazySequenceFromBlock:^id<PBTSequence>{
        id<PBTSequence> sequence = [PBTSequence sequenceFromArray:roseTrees];

        id<PBTSequence> oneLessTreeSequence = [sequence sequenceByApplyingIndexedBlock:^id(NSUInteger index, PBTRoseTree *_roseTree) {
            return [[[sequence sequenceByExcludingIndex:index] objectEnumerator] allObjects];
        }];

        id<PBTSequence> permutationSequence = [self permutationsOfRoseTrees:roseTrees];
        return [oneLessTreeSequence sequenceByConcatenatingSequence:permutationSequence];
    }];
}

+ (instancetype)shrinkTreeFromRoseTrees:(NSArray *)roseTrees merger:(id(^)(NSArray *values))merger
{
    if (!roseTrees.count) {
        return [[PBTRoseTree alloc] initWithValue:@[]];
    }

    id<PBTSequence> children = [[self sequenceByExpandingRoseTrees:roseTrees] sequenceByApplyingBlock:^id(id<PBTSequence> trees) {
        return [self shrinkTreeFromRoseTrees:[[trees objectEnumerator] allObjects] merger:merger];
    }];

    id value = merger([roseTrees valueForKey:@"value"]);
    return [[PBTRoseTree alloc] initWithValue:value
                                     children:children];
}

+ (instancetype)zipTreeFromRoseTrees:(NSArray *)roseTrees byApplying:(id(^)(NSArray *values))block
{
    id<PBTSequence> children = [[self permutationsOfRoseTrees:roseTrees] sequenceByApplyingBlock:^id(NSArray *subtrees) {
        return [self zipTreeFromRoseTrees:subtrees byApplying:block];
    }];

    return [[PBTRoseTree alloc] initWithValue:block([roseTrees valueForKey:@"value"])
                                     children:children];
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
#ifdef DEBUG
        self.createdCallStack = [NSThread callStackSymbols];
#endif
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
    return [_children sequenceByApplyingBlock:^id(PBTRoseTree *tree) {
        tree.parent = self;
        return tree;
    }];
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
    NSString *valueDesc = [self.value description] ?: @"nil";
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"[\n ]+" options:0 error:nil];
    valueDesc = [regexp stringByReplacingMatchesInString:valueDesc options:0 range:NSMakeRange(0, valueDesc.length) withTemplate:@" "];
    [string appendString:valueDesc];

    if ([self.children firstObject]) {
        [string appendString:@", {\n  "];
        NSString *desc = [self.children description];
        NSArray *lines = [[desc substringWithRange:NSMakeRange(@"SEQ(".length, desc.length - @"SEQ()".length)] componentsSeparatedByString:@"\n"];
        [string appendString:[lines componentsJoinedByString:@"\n  "]];
        [string appendString:@"\n}"];
    }

    [string appendString:@">"];
    return string;
}

@end

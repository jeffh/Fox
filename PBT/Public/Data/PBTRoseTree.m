#import "PBTRoseTree.h"
#import "PBTSequence.h"


@implementation PBTRoseTree

+ (id<PBTSequence>)permutationsOfRoseTrees:(NSArray *)roseTrees
{
    if (!roseTrees.count) {
        return [PBTSequence sequence];
    }
    PBTRoseTree *nextRoseTree = roseTrees[0];
    return [self _permutationsOfRoseTrees:roseTrees
                             currentIndex:0
                        remainingChildren:nextRoseTree.children];
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

+ (instancetype)shrinkTreeFromRoseTrees:(NSArray *)roseTrees
{
    if (!roseTrees.count) {
        return [[PBTRoseTree alloc] initWithValue:@[]];
    }

    id<PBTSequence> children = [[self sequenceByExpandingRoseTrees:roseTrees] sequenceByApplyingBlock:^id(id<PBTSequence> trees) {
        return [self shrinkTreeFromRoseTrees:[[trees objectEnumerator] allObjects]];
    }];

    return [[PBTRoseTree alloc] initWithValue:[roseTrees valueForKey:@"value"]
                                     children:children];
}

+ (instancetype)zipTreeFromRoseTrees:(NSArray *)roseTrees
{
    id<PBTSequence> children = [[self permutationsOfRoseTrees:roseTrees] sequenceByApplyingBlock:^id(NSArray *subtrees) {
        return [self zipTreeFromRoseTrees:subtrees];
    }];

    return [[PBTRoseTree alloc] initWithValue:[roseTrees valueForKey:@"value"]
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
        _value = value;
        _children = children ?: [PBTSequence sequence];
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

#pragma mark - Private

+ (id<PBTSequence>)_permutationsOfRoseTrees:(NSArray *)roseTrees currentIndex:(NSUInteger)index remainingChildren:(id<PBTSequence>)children
{
    return [PBTSequence lazySequenceFromBlock:^id<PBTSequence>{
        if ([children firstObject]) {
            NSMutableArray *permutation = [roseTrees mutableCopy];
            permutation[index] = [children firstObject];
            return [PBTSequence sequenceWithObject:permutation
                                 remainingSequence:[self _permutationsOfRoseTrees:roseTrees
                                                                     currentIndex:index
                                                                remainingChildren:[children remainingSequence]]];
        } else if (index + 1 < roseTrees.count) {
            PBTRoseTree *nextRoseTree = roseTrees[index + 1];
            return [self _permutationsOfRoseTrees:roseTrees
                                     currentIndex:index + 1
                                remainingChildren:nextRoseTree.children];
        } else {
            return nil;
        }
    }];
}

@end

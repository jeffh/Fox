#import "FOXRoseTree.h"
#import "FOXSequence.h"


@implementation FOXRoseTree

+ (id<FOXSequence>)permutationsOfRoseTrees:(NSArray *)roseTrees
{
    if (!roseTrees.count) {
        return [FOXSequence sequence];
    }
    FOXRoseTree *nextRoseTree = roseTrees[0];
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
    return [[FOXRoseTree alloc] initWithValue:[roseTreeLiteral firstObject]
                                     children:[FOXSequence sequenceFromArray:subtrees]];
}

+ (instancetype)joinedTreeFromNestedRoseTree:(FOXRoseTree *)roseTree
{
    FOXRoseTree *rootTree = roseTree.value;
    id<FOXSequence> children = [rootTree.children sequenceByApplyingBlock:^id(FOXRoseTree *tree) {
        return [self joinedTreeFromNestedRoseTree:tree];
    }];
    children = [children sequenceByConcatenatingSequence:roseTree.children];
    return [[FOXRoseTree alloc] initWithValue:rootTree.value
                                     children:children];
}

+ (id<FOXSequence>)sequenceByExpandingRoseTrees:(NSArray *)roseTrees
{
    return [FOXSequence lazySequenceFromBlock:^id<FOXSequence> {
        id<FOXSequence> sequence = [FOXSequence sequenceFromArray:roseTrees];

        id<FOXSequence> oneLessTreeSequence = [sequence sequenceByApplyingIndexedBlock:^id(NSUInteger index, FOXRoseTree *_roseTree) {
            return [[[sequence sequenceByExcludingIndex:index] objectEnumerator] allObjects];
        }];

        id<FOXSequence> permutationSequence = [self permutationsOfRoseTrees:roseTrees];
        return [oneLessTreeSequence sequenceByConcatenatingSequence:permutationSequence];
    }];
}

+ (instancetype)shrinkTreeFromRoseTrees:(NSArray *)roseTrees
{
    if (!roseTrees.count) {
        return [[FOXRoseTree alloc] initWithValue:@[]];
    }

    id<FOXSequence> children = [[self sequenceByExpandingRoseTrees:roseTrees] sequenceByApplyingBlock:^id(id<FOXSequence> trees) {
        return [self shrinkTreeFromRoseTrees:[[trees objectEnumerator] allObjects]];
    }];

    return [[FOXRoseTree alloc] initWithValue:[roseTrees valueForKey:@"value"]
                                     children:children];
}

+ (instancetype)zipTreeFromRoseTrees:(NSArray *)roseTrees
{
    id<FOXSequence> children = [[self permutationsOfRoseTrees:roseTrees] sequenceByApplyingBlock:^id(NSArray *subtrees) {
        return [self zipTreeFromRoseTrees:subtrees];
    }];

    return [[FOXRoseTree alloc] initWithValue:[roseTrees valueForKey:@"value"]
                                     children:children];
}


- (instancetype)initWithValue:(id)value
{
    return [self initWithValue:value children:nil];
}

- (instancetype)initWithValue:(id)value children:(id<FOXSequence>)children
{
    self = [self init];
    if (self) {
        _value = value;
        _children = children ?: [FOXSequence sequence];
    }
    return self;
}

- (FOXRoseTree *)treeByApplyingBlock:(id(^)(id element))block
{
    return [[FOXRoseTree alloc] initWithValue:block(self.value)
                                     children:[self.children sequenceByApplyingBlock:^id(FOXRoseTree *subtree) {
        return [subtree treeByApplyingBlock:block];
    }]];
}

- (FOXRoseTree *)treeFilterChildrenByBlock:(BOOL(^)(id element))block
{
    return [[FOXRoseTree alloc] initWithValue:self.value
                                     children:[[self.children sequenceFilteredByBlock:^BOOL(FOXRoseTree *subtree) {
        return block(subtree.value);
    }] sequenceByApplyingBlock:^id(FOXRoseTree *subtree) {
        return [subtree treeFilterChildrenByBlock:block];
    }]];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    FOXRoseTree *other = object;

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

+ (id<FOXSequence>)_permutationsOfRoseTrees:(NSArray *)roseTrees currentIndex:(NSUInteger)index remainingChildren:(id<FOXSequence>)children
{
    return [FOXSequence lazySequenceFromBlock:^id<FOXSequence> {
        if ([children firstObject]) {
            NSMutableArray *permutation = [roseTrees mutableCopy];
            permutation[index] = [children firstObject];
            return [FOXSequence sequenceWithObject:permutation
                                 remainingSequence:[self _permutationsOfRoseTrees:roseTrees
                                                                     currentIndex:index
                                                                remainingChildren:[children remainingSequence]]];
        } else if (index + 1 < roseTrees.count) {
            FOXRoseTree *nextRoseTree = roseTrees[index + 1];
            return [self _permutationsOfRoseTrees:roseTrees
                                     currentIndex:index + 1
                                remainingChildren:nextRoseTree.children];
        } else {
            return nil;
        }
    }];
}

@end

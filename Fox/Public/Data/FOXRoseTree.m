#import "FOXRoseTree.h"
#import "FOXSequence.h"
#import "FOXPrettyArray.h"
#import "FOXStringUtil.h"
#import "FOXObjectiveCRepresentation.h"

@interface FOXRoseTree () <FOXObjectiveCRepresentation>
@end

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
    id value = [roseTreeLiteral firstObject];
    if ([value isEqual:[NSNull null]]) {
        value = nil;
    }
    return [[[self class] alloc] initWithValue:value
                                      children:[FOXSequence sequenceFromArray:subtrees]];
}

+ (instancetype)joinedTreeFromNestedRoseTree:(FOXRoseTree *)roseTree
{
    FOXRoseTree *firstTree = roseTree.value;
    id<FOXSequence> childrenChildren = [roseTree.children sequenceByMapping:^(FOXRoseTree *tree){
        return [self joinedTreeFromNestedRoseTree:tree];
    }];
    id<FOXSequence> mergedChildren = [childrenChildren sequenceByAppending:firstTree.children];
    return [[[self class] alloc] initWithValue:firstTree.value
                                      children:mergedChildren];
}

+ (id<FOXSequence>)sequenceByExpandingRoseTrees:(NSArray *)roseTrees
{
    return [FOXSequence lazySequenceFromBlock:^id<FOXSequence> {
        id<FOXSequence> sequence = [FOXSequence sequenceFromArray:roseTrees];

        id<FOXSequence> oneLessTreeSequence = [sequence sequenceByMappingWithIndex:^id(NSUInteger index, FOXRoseTree *_roseTree) {
            return [[[sequence sequenceByDroppingIndex:index] objectEnumerator] allObjects];
        }];

        id<FOXSequence> permutationSequence = [self permutationsOfRoseTrees:roseTrees];
        return [oneLessTreeSequence sequenceByAppending:permutationSequence];
    }];
}

+ (instancetype)shrinkTreeFromRoseTrees:(NSArray *)roseTrees
{
    if (!roseTrees.count) {
        return [[[self class] alloc] initWithValue:@[]];
    }

    id<FOXSequence> children = [[self sequenceByExpandingRoseTrees:roseTrees] sequenceByMapping:^id(id<FOXSequence> trees) {
        return [self shrinkTreeFromRoseTrees:[[trees objectEnumerator] allObjects]];
    }];

    FOXPrettyArray *values = [FOXPrettyArray arrayWithArray:[roseTrees valueForKey:@"value"]];
    return [[[self class] alloc] initWithValue:values
                                     children:children];
}

+ (instancetype)zipTreeFromRoseTrees:(NSArray *)roseTrees
{
    id<FOXSequence> children = [[self permutationsOfRoseTrees:roseTrees] sequenceByMapping:^id(NSArray *subtrees) {
        return [self zipTreeFromRoseTrees:subtrees];
    }];

    FOXPrettyArray *values = [FOXPrettyArray arrayWithArray:[roseTrees valueForKey:@"value"]];
    return [[FOXRoseTree alloc] initWithValue:values
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

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _value = [aDecoder decodeObjectForKey:@"value"];
        _children = [aDecoder decodeObjectForKey:@"children"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.children forKey:@"children"];
}

#pragma mark - Protected

- (void)freeInternals
{
    _value = nil;
    _children = nil;
}

#pragma mark - Public

- (instancetype)treeByApplyingBlock:(id(^)(id element))block
{
    return [[[self class] alloc] initWithValue:block(self.value)
                                      children:[self.children sequenceByMapping:^id(FOXRoseTree *subtree) {
        return [subtree treeByApplyingBlock:block];
    }]];
}

- (instancetype)treeFilterChildrenByBlock:(BOOL(^)(id element))block
{
    return [[[self class] alloc] initWithValue:self.value
                                      children:[[self.children sequenceByFiltering:^BOOL(FOXRoseTree *subtree) {
        return block(subtree.value);
    }] sequenceByMapping:^id(FOXRoseTree *subtree) {
        return [subtree treeFilterChildrenByBlock:block];
    }]];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
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

- (NSString *)objectiveCStringRepresentation
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"[%@ treeFromArray:@[",
                               NSStringFromClass([self class])];
    NSString *valueDesc = FOXRepr(self.value);
    if ([self.value isKindOfClass:[NSArray class]]) {
        valueDesc = [valueDesc stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    [string appendString:FOXIndentString(valueDesc, 2)];
    [string appendString:@",\n"];

    [string appendString:FOXRepr(self.children)];

    [string appendString:@"]"];
    return string;
}

- (NSString *)description
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"<("];
    NSString *valueDesc = self.value ? [self.value description] : @"nil";
    if ([self.value isKindOfClass:[NSArray class]]) {
        valueDesc = [valueDesc stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    [string appendString:FOXIndentString(valueDesc, 2)];
    [string appendString:@")"];

    if ([self.children firstObject]) {
        [string appendString:@" {\n"];
        for (FOXRoseTree *tree in self.children) {
            [string appendString:@"    "];
            [string appendString:FOXIndentString([tree description], 2)];
            [string appendString:@"\n"];
        }
        [string appendString:@"}"];
    }

    [string appendString:@">"];
    return string;
}

#pragma mark - Private

+ (id<FOXSequence>)_permutationsOfRoseTrees:(NSArray *)roseTrees
                               currentIndex:(NSUInteger)index
                          remainingChildren:(id<FOXSequence>)children
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

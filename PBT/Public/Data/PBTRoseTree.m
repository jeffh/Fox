#import "PBTRoseTree.h"
#import "PBTConcreteSequence.h"
#import "PBTLazySequence.h"


@implementation PBTRoseTree

+ (instancetype)treeFromArray:(NSArray *)roseTreeLiteral
{
    NSParameterAssert(roseTreeLiteral.count == 2);
    id<PBTSequence> children = [[PBTConcreteSequence sequenceFromArray:roseTreeLiteral[1]] sequenceByApplyingBlock:^id(NSArray *subtree) {
        return [self treeFromArray:subtree];
    }];
    return [[PBTRoseTree alloc] initWithValue:[roseTreeLiteral firstObject]
                                     children:children];
}

- (instancetype)initWithValue:(id)value
{
    return [self initWithValue:value children:nil];
}

- (instancetype)initWithValue:(id)value children:(id<PBTSequence>)children
{
    self = [super init];
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
    return (37 << 1) ^ [self.value hash] ^ [self.children hash];
}

- (NSString *)description
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@: ",
                               NSStringFromClass([self class])];
    [string appendString:[self.value description]];

    if (self.children.count) {
        [string appendString:@", "];
        [string appendString:[self.children description]];
    }

    [string appendString:@">"];
    return string;
}

@end

#import "PBTChooseGenerator.h"
#import "PBTSequence.h"
#import "PBTDeterministicRandom.h"
#import "PBTRoseTree.h"
#import "PBTShrinkingIntegerSequence.h"


@interface PBTChooseGenerator ()
@property (nonatomic) NSNumber *lowerNumber;
@property (nonatomic) NSNumber *upperNumber;
@end


@implementation PBTChooseGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithLowerBound:(NSNumber *)lowerNumber
                        upperBound:(NSNumber *)upperNumber
{
    self = [super init];
    if (self) {
        self.lowerNumber = lowerNumber;
        self.upperNumber = upperNumber;
    }
    return self;
}

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize
{
    NSInteger lower = [self.lowerNumber integerValue];
    NSInteger upper = [self.upperNumber integerValue];
    NSInteger randomInteger = [random randomIntegerWithinMinimum:lower
                                                      andMaximum:upper];
    NSNumber *randValue = @(randomInteger);
    id<PBTSequence> seqOfTrees = [self sequenceOfNumbersSmallerThan:randValue];
    seqOfTrees = [seqOfTrees sequenceByApplyingBlock:^id(NSNumber *value) {
        return [self roseTreeWithMaxNumber:value];
    }];
    PBTRoseTree *tree = [[PBTRoseTree alloc] initWithValue:randValue children:seqOfTrees];
    return [tree treeFilterChildrenByBlock:^BOOL(NSNumber *value) {
        return [value compare:self.lowerNumber] != NSOrderedAscending
            && [value compare:self.upperNumber] != NSOrderedDescending;
    }];
}

#pragma mark - Private

- (PBTRoseTree *)roseTreeWithMaxNumber:(NSNumber *)number
{
    id<PBTSequence> children = [self sequenceOfNumbersSmallerThan:number];
    return [[PBTRoseTree alloc] initWithValue:number
                              children:[children sequenceByApplyingBlock:^id(NSNumber *value) {
        return [self roseTreeWithMaxNumber:value];
    }]];
}

- (id<PBTSequence>)sequenceOfNumbersSmallerThan:(NSNumber *)number
{
    return [PBTShrinkingIntegerSequence sequenceOfNumbersSmallerThan:number];
}


@end

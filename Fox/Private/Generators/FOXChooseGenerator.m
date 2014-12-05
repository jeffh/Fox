#import "FOXChooseGenerator.h"
#import "FOXSequence.h"
#import "FOXDeterministicRandom.h"
#import "FOXRoseTree.h"
#import "FOXShrinkingIntegerSequence.h"
#import "FOXNumericRoseTree.h"


@interface FOXChooseGenerator ()
@property (nonatomic) NSNumber *lowerNumber;
@property (nonatomic) NSNumber *upperNumber;
@end


@implementation FOXChooseGenerator

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

- (FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize
{
    NSInteger lower = [self.lowerNumber integerValue];
    NSInteger upper = [self.upperNumber integerValue];
    NSInteger randomInteger = [random randomIntegerWithinMinimum:lower
                                                      andMaximum:upper];
    NSNumber *randValue = @(randomInteger);
    FOXRoseTree *tree = [FOXNumericRoseTree roseTreeWithMaxNumber:randValue];
    return [tree treeFilterChildrenByBlock:^BOOL(NSNumber *value) {
        return [value compare:self.lowerNumber] != NSOrderedAscending
            && [value compare:self.upperNumber] != NSOrderedDescending;
    }];
}

@end

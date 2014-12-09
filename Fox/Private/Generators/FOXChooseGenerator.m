#import "FOXChooseGenerator.h"
#import "FOXSequence.h"
#import "FOXRandom.h"
#import "FOXRoseTree.h"


@interface FOXChooseGenerator ()
@property (nonatomic) NSNumber *lowerNumber;
@property (nonatomic) NSNumber *upperNumber;
@end


@implementation FOXChooseGenerator

static NSMutableDictionary *__cache;

+ (void)initialize
{
    [super initialize];
    __cache = [NSMutableDictionary dictionary];
}

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
        NSAssert([self.lowerNumber compare:self.upperNumber] != NSOrderedDescending, @"Expected %@ <= %@",
                 self.lowerNumber, self.upperNumber);
    }
    return self;
}

- (FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize
{
    long long lower = [self.lowerNumber longLongValue];
    long long upper = [self.upperNumber longLongValue];
    NSInteger randomInteger = [random randomIntegerWithinMinimum:lower
                                                      andMaximum:upper];
    NSNumber *randValue = @(randomInteger);
    FOXRoseTree *tree = [self roseTreeWithMaxNumber:randValue];
    return [tree treeFilterChildrenByBlock:^BOOL(NSNumber *value) {
        return [value compare:self.lowerNumber] != NSOrderedAscending
            && [value compare:self.upperNumber] != NSOrderedDescending;
    }];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p [%@, %@]>",
            NSStringFromClass([self class]),
            self,
            self.lowerNumber,
            self.upperNumber];
}

#pragma mark - Private

- (FOXRoseTree *)roseTreeWithMaxNumber:(NSNumber *)number
{
    FOXRoseTree *result = [__cache objectForKey:number];
    if (!result) {
        id<FOXSequence> children = [self sequenceOfNumbersSmallerThan:number];
        result = [[FOXRoseTree alloc] initWithValue:number
                                           children:[children sequenceByMapping:^id(NSNumber *value) {
            return [self roseTreeWithMaxNumber:value];
        }]];

        [__cache setObject:result forKey:number];
    }
    return result;
}

- (id<FOXSequence>)sequenceOfNumbersSmallerThan:(NSNumber *)number
{
    if ([number compare:@0] == NSOrderedSame) {
        return nil;
    }

    id<FOXSequence> halves = [self sequenceOfHalvesOfNumber:number];
    id<FOXSequence> result = [halves sequenceByMapping:^id(NSNumber *value) {
        return @([number longLongValue] - [value longLongValue]);
    }];
    return result;
}

- (id<FOXSequence>)sequenceOfHalvesOfNumber:(NSNumber *)number
{
    if ([number compare:@0] == NSOrderedSame) {
        return nil;
    }
    return [FOXSequence lazySequenceFromBlock:^id<FOXSequence>{
        long long halfNumber = [number longLongValue] / 2;
        id<FOXSequence> remainingSequence = [self sequenceOfHalvesOfNumber:@(halfNumber)];
        return [FOXSequence sequenceWithObject:number
                             remainingSequence:remainingSequence];
    }];
}

@end

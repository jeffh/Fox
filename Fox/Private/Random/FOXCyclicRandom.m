#import "FOXCyclicRandom.h"

@interface FOXCyclicRandom ()

@property (nonatomic) NSArray *values;
@property (nonatomic) NSUInteger offset;
@property (nonatomic) long long minValue;
@property (nonatomic) long long maxValue;

@end

@implementation FOXCyclicRandom

@synthesize seed;

- (instancetype)initWithValues:(NSArray *)values
{
    self = [super init];
    if (self) {
        self.values = values;
        self.offset = 0;

        NSArray *sortedValues = [values sortedArrayUsingSelector:@selector(compare:)];
        self.minValue = [sortedValues[0] longLongValue];
        self.maxValue = [sortedValues[0] longLongValue];
    }
    return self;
}

- (long long)randomInteger
{
    NSNumber *result = self.values[self.offset++];
    if (self.offset >= self.values.count) {
        self.offset = 0;
    }
    return [result longLongValue];
}

- (long long)randomIntegerWithinMinimum:(long long)minimumNumber andMaximum:(long long)maximumNumber
{
    long long value = [self randomInteger];
    long long delta = maximumNumber - minimumNumber;
    if (delta) {
        return ((value - self.minValue) % delta) + minimumNumber;
    }
    return 0;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithValues:self.values];
}

@end

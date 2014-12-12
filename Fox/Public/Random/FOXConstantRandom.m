#import "FOXConstantRandom.h"


@implementation FOXConstantRandom

@synthesize seed = _seed;

- (instancetype)init
{
    return [self initWithValue:0];
}

- (instancetype)initWithValue:(long long)value
{
    self = [super init];
    if (self) {
        self.value = value;
    }
    return self;
}

- (long long)randomInteger
{
    return self.value;
}

- (long long)randomIntegerWithinMinimum:(long long)minimumNumber andMaximum:(long long)maximumNumber
{
    return MAX(MIN(self.value, maximumNumber), minimumNumber);
}

@end

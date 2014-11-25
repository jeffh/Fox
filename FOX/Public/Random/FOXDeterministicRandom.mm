#import "FOXDeterministicRandom.h"
#import <random>

@implementation FOXDeterministicRandom {
    uint32_t _seed;
    std::mt19937 _generator;
    std::uniform_int_distribution<NSInteger> _distribution;
}

- (instancetype)init
{
    return [self initWithSeed:(uint32_t)time(NULL)];
}

- (instancetype)initWithSeed:(uint32_t)seed
{
    self = [super init];
    if (self) {
        _distribution = std::uniform_int_distribution<NSInteger>(std::numeric_limits<NSInteger>::min(),
                                                                 std::numeric_limits<NSInteger>::max());
        self.seed = seed;
    }
    return self;
}

- (uint32_t)seed
{
    return _seed;
}

- (void)setSeed:(uint32_t)seed
{
    _seed = seed;
    _generator = std::mt19937(seed);
}

- (NSInteger)randomInteger
{
    return _distribution(_generator);
}

- (NSInteger)randomIntegerWithinMinimum:(NSInteger)minimumNumber andMaximum:(NSInteger)maximumNumber
{
    NSInteger difference = maximumNumber - minimumNumber;
    std::uniform_int_distribution<NSInteger> distributionRange(0, difference);
    NSInteger randomNumber = distributionRange(_generator);
    return randomNumber + minimumNumber;
}

@end

#import "FOXDeterministicRandom.h"
#import <random>

@implementation FOXDeterministicRandom {
    unsigned long long _seed;
    std::mt19937_64 _generator;
    std::uniform_int_distribution<NSInteger> _distribution;
}

@synthesize seed = _seed;

- (instancetype)init
{
    return [self initWithSeed:(long long)time(NULL)];
}

- (instancetype)initWithSeed:(unsigned long long)seed
{
    self = [super init];
    if (self) {
        _distribution = std::uniform_int_distribution<NSInteger>(std::numeric_limits<NSInteger>::min(),
                                                                 std::numeric_limits<NSInteger>::max());
        self.seed = seed;
    }
    return self;
}

- (void)setSeed:(unsigned long long)seed
{
    _seed = seed;
    _generator = std::mt19937_64(seed);
}

- (long long)randomInteger
{
    return _distribution(_generator);
}

- (long long)randomIntegerWithinMinimum:(long long)minimumNumber andMaximum:(long long)maximumNumber
{
    NSInteger difference = maximumNumber - minimumNumber;
    std::uniform_int_distribution<NSInteger> distributionRange(0, difference);
    NSInteger randomNumber = distributionRange(_generator);
    return randomNumber + minimumNumber;
}

@end

#import "FOXDeterministicRandom.h"
#import <random>

#ifdef __LP64__
typedef std::mt19937_64 rng_engine;
#else
typedef std::mt19937 rng_engine;
#endif

@implementation FOXDeterministicRandom {
    NSUInteger _seed;
    rng_engine _generator;
    std::uniform_int_distribution<NSInteger> _distribution;
}

@synthesize seed = _seed;

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

- (void)setSeed:(NSUInteger)seed
{
    _seed = seed;
    _generator = rng_engine(seed);
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

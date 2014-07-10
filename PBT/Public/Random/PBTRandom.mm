#import "PBTRandom.h"
#import "PBTSequence.h"


@implementation PBTRandom {
    uint32_t _seed;
    std::mt19937 _generator;
    std::uniform_real_distribution<double> _distribution;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _distribution = std::uniform_real_distribution<double>(std::numeric_limits<double>::min(),
                                                               std::numeric_limits<double>::max());
        [self setSeed:(uint32_t)time(NULL)];
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

- (double)randomDouble
{
    return _distribution(_generator);
}

- (double)randomDoubleWithinMinimum:(double)minDouble andMaximum:(double)maxDouble
{
    std::uniform_real_distribution<double> distributionRange(minDouble, maxDouble);
    return distributionRange(_generator);
}

@end

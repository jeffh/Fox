#import "PBTConstantRandom.h"


@interface PBTConstantRandom ()

@property (nonatomic) double doubleValue;
@property (nonatomic) uint32_t seed;

@end


@implementation PBTConstantRandom

- (instancetype)init
{
    return [self initWithDoubleValue:0.0];
}

- (instancetype)initWithDoubleValue:(double)doubleValue
{
    self = [super init];
    if (self) {
        self.doubleValue = doubleValue;
    }
    return self;
}

- (double)randomDouble
{
    return self.doubleValue;
}

- (double)randomDoubleWithinMinimum:(double)minDouble andMaximum:(double)maxDouble
{
    return MAX(MIN(self.doubleValue, maxDouble), minDouble);
}

@end

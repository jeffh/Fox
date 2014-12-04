#import "FOXConstantRandom.h"


@implementation FOXConstantRandom

@synthesize seed = _seed;

- (instancetype)init
{
    return [self initWithValue:0];
}

- (instancetype)initWithValue:(NSInteger)value
{
    self = [super init];
    if (self) {
        self.value = value;
    }
    return self;
}

- (NSInteger)randomInteger
{
    return self.value;
}

- (NSInteger)randomIntegerWithinMinimum:(NSInteger)minimumNumber andMaximum:(NSInteger)maximumNumber
{
    return MAX(MIN(self.value, maximumNumber), minimumNumber);
}

@end

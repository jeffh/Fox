#import "FOXConstantRandom.h"


@interface FOXConstantRandom ()

@property (nonatomic) NSInteger value;
@property (nonatomic) uint32_t seed;

@end


@implementation FOXConstantRandom

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

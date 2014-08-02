#import "PBTConstantRandom.h"


@interface PBTConstantRandom ()

@property (nonatomic) NSInteger value;
@property (nonatomic) uint32_t seed;

@end


@implementation PBTConstantRandom

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

- (double)randomInteger
{
    return self.value;
}

- (double)randomIntegerWithinMinimum:(NSInteger)minimumNumber andMaximum:(NSInteger)maximumNumber
{
    return MAX(MIN(self.value, maximumNumber), minimumNumber);
}

@end

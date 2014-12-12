#import "FOXDeterministicRandom.h"


@interface FOXConstantRandom : NSObject <FOXRandom>

@property (nonatomic) long long value;

- (instancetype)init;
- (instancetype)initWithValue:(long long)value;

@end

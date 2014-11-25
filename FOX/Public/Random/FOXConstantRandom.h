#import "FOXDeterministicRandom.h"


@interface FOXConstantRandom : NSObject <FOXRandom>

- (instancetype)init;
- (instancetype)initWithValue:(NSInteger)value;

@end

#import "FOXRandom.h"


@interface FOXDeterministicRandom : NSObject <FOXRandom>

- (instancetype)init;
- (instancetype)initWithSeed:(uint32_t)seed;

@end

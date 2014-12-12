#import "FOXRandom.h"


@interface FOXDeterministicRandom : NSObject <FOXRandom>

- (instancetype)init;
- (instancetype)initWithSeed:(unsigned long long)seed;

@end

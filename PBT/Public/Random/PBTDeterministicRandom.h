#import "PBTRandom.h"


@interface PBTDeterministicRandom : NSObject <PBTRandom>

- (instancetype)init;
- (instancetype)initWithSeed:(uint32_t)seed;

@end

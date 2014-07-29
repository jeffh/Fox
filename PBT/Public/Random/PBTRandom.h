#import <Foundation/Foundation.h>
#import "PBTRandom.h"

@protocol PBTRandom <NSObject>

- (uint32_t)seed;
- (void)setSeed:(uint32_t)seed;
- (double)randomDouble;
- (double)randomDoubleWithinMinimum:(double)minDouble
                         andMaximum:(double)maxDouble;

@end

@interface PBTRandom : NSObject <PBTRandom>

- (instancetype)init;
- (uint32_t)seed;
- (void)setSeed:(uint32_t)seed;

- (double)randomDouble;
- (double)randomDoubleWithinMinimum:(double)minDouble
                         andMaximum:(double)maxDouble;

@end

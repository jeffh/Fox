#import <Foundation/Foundation.h>
#import "PBTRandom.h"

@protocol PBTRandom <NSObject>

- (uint32_t)seed;
- (void)setSeed:(uint32_t)seed;
- (double)randomInteger;
- (double)randomIntegerWithinMinimum:(NSInteger)minimumNumber
                          andMaximum:(NSInteger)maximumNumber;

@end

@interface PBTRandom : NSObject <PBTRandom>

- (instancetype)init;
- (instancetype)initWithSeed:(uint32_t)seed;

@end

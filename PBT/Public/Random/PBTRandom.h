#import <Foundation/Foundation.h>


@protocol PBTRandom <NSObject>

- (uint32_t)seed;
- (void)setSeed:(uint32_t)seed;
- (NSInteger)randomInteger;
- (NSInteger)randomIntegerWithinMinimum:(NSInteger)minimumNumber
                             andMaximum:(NSInteger)maximumNumber;

@end


#import <Foundation/Foundation.h>


/**
 An object that conforms to this protocol can provide randomness.
 That is, it can produce random integers within a specified range.

 It must also support the concept of "seeds"--that is, a randomness
 provider, given the same seed, must produce the same data.
 */
@protocol FOXRandom<NSObject>

- (uint32_t)seed;
- (void)setSeed:(uint32_t)seed;
- (NSInteger)randomInteger;
- (NSInteger)randomIntegerWithinMinimum:(NSInteger)minimumNumber
                             andMaximum:(NSInteger)maximumNumber;

@end


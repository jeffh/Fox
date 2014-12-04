#import <Foundation/Foundation.h>


/*! An object that conforms to this protocol can provide randomness.
 * That is, it can produce random integers within a specified range.
 *
 * It must also support the concept of "seeds"--that is, a randomness
 * provider, given the same seed, must produce the same data.
 */
@protocol FOXRandom <NSObject>

/*! Represent the seed of the random number generator.
 *
 *  This is emitted by the runner, but can also be explicitly set by
 *  the runner if the user wants to set the seed for reproducing a
 *  generated test failure.
 */
@property (nonatomic) NSUInteger seed;

/*! Generates a random integer from within range of minimum and
 *  maximum range of NSInteger.
 */
- (NSInteger)randomInteger;

/*! Generates a random integer from within the given range (inclusive).
 */
- (NSInteger)randomIntegerWithinMinimum:(NSInteger)minimumNumber
                             andMaximum:(NSInteger)maximumNumber;

@end


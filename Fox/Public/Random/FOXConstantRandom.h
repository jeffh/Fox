#import "FOXDeterministicRandom.h"


@interface FOXConstantRandom : NSObject <FOXRandom>

@property (nonatomic) NSInteger value;

- (instancetype)init;
- (instancetype)initWithValue:(NSInteger)value;

@end

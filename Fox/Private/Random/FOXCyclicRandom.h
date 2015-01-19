#import "FOXRandom.h"


@interface FOXCyclicRandom : NSObject <FOXRandom>

- (instancetype)initWithValues:(NSArray *)values;

@end

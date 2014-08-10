#import "PBTRandom.h"


@interface PBTConstantRandom : NSObject <PBTRandom>

- (instancetype)init;
- (instancetype)initWithValue:(NSInteger)value;

@end

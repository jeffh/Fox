#import "PBTGenerator.h"


@interface PBTChooseGenerator : NSObject <PBTGenerator>

- (instancetype)initWithLowerBound:(NSNumber *)lowerNumber
                        upperBound:(NSNumber *)upperNumber;

@end

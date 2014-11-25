#import "FOXGenerator.h"


@interface FOXChooseGenerator : NSObject <FOXGenerator>

- (instancetype)initWithLowerBound:(NSNumber *)lowerNumber
                        upperBound:(NSNumber *)upperNumber;

@end

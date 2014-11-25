#import "FOXGenerator.h"
#import "FOXSequence.h"


@interface FOXSequenceGenerator : NSObject <FOXGenerator>

- (instancetype)initWithGenerators:(id<FOXSequence>)generators;

@end

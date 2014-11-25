#import "FOXGenerator.h"


@protocol FOXSequence;


@interface FOXTupleGenerator : NSObject <FOXGenerator>

- (instancetype)initWithGenerators:(id<FOXSequence>)generators;

@end

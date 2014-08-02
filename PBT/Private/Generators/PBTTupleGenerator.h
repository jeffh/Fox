#import "PBTGenerator.h"


@interface PBTTupleGenerator : NSObject <PBTGenerator>

- (instancetype)initWithGenerators:(id<PBTSequence>)generators;

@end

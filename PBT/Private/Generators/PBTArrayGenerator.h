#import "PBTGenerator.h"


@interface PBTArrayGenerator : NSObject <PBTGenerator>

- (instancetype)initWithGenerators:(id<PBTSequence>)generators;

@end

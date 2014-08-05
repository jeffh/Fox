#import "PBTGenerator.h"
#import "PBTSequence.h"


@interface PBTSequenceGenerator : NSObject <PBTGenerator>

- (instancetype)initWithGenerators:(id<PBTSequence>)generators;

@end

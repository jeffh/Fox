#import "PBTGenerator.h"
#import "PBTSequence.h"


@interface PBTSequenceGenerator : NSObject <PBTGenerator>

- (instancetype)initWithGenerators:(id<PBTSequence>)generators
                           reducer:(PBTRoseTree *(^)(id<PBTGenerator> accumGenerator, id<PBTGenerator> itemGenerator))shrinker;

@end

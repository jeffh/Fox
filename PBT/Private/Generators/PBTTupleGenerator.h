#import "PBTGenerator.h"


@protocol PBTSequence;


@interface PBTTupleGenerator : NSObject <PBTGenerator>

- (instancetype)initWithGenerators:(id<PBTSequence>)generators;

@end

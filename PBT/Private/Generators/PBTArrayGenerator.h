#import "PBTGenerator.h"

@protocol PBTSequence;


@interface PBTArrayGenerator : NSObject <PBTGenerator>

- (instancetype)initWithGenerators:(id<PBTSequence>)generators;

@end

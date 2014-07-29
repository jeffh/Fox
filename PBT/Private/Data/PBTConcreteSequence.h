#import "PBTSequence.h"

@interface PBTConcreteSequence : PBTSequence

- (instancetype)init;
- (instancetype)initWithObject:(id)object;
- (instancetype)initWithObject:(id)object
             remainingSequence:(id<PBTSequence>)sequence;

@end

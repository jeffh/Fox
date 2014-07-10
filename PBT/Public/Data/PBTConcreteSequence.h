#import "PBTAbstractSequence.h"


@interface PBTConcreteSequence : PBTAbstractSequence

- (instancetype)init;
- (instancetype)initWithObject:(id)object;
- (instancetype)initWithObject:(id)object
             remainingSequence:(id<PBTSequence>)sequence;

@end

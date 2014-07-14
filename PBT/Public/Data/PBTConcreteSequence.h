#import "PBTAbstractSequence.h"


@interface PBTConcreteSequence : PBTAbstractSequence

+ (instancetype)sequenceFromArray:(NSArray *)array;
- (instancetype)init;
- (instancetype)initWithObject:(id)object;
- (instancetype)initWithObject:(id)object
             remainingSequence:(id<PBTSequence>)sequence;

@end

#import "FOXSequence.h"

@interface FOXConcreteSequence : FOXSequence

- (instancetype)init;
- (instancetype)initWithObject:(id)object;
- (instancetype)initWithObject:(id)object
             remainingSequence:(id<FOXSequence>)sequence;

@end

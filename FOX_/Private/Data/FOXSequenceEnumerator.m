#import "FOXSequenceEnumerator.h"


@implementation FOXSequenceEnumerator

- (id)initWithSequence:(id<FOXSequence>)sequence
{
    if (self = [super init]) {
        self.sequence = sequence;
    }
    return self;
}

- (id)nextObject
{
    id result = [self.sequence firstObject];
    self.sequence = [self.sequence remainingSequence];
    return result;
}

@end

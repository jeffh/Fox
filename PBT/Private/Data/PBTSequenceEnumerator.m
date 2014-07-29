#import "PBTSequenceEnumerator.h"


@implementation PBTSequenceEnumerator

- (id)initWithSequence:(id<PBTSequence>)sequence
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

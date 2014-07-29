#import "PBTSequence.h"


@interface PBTSequenceEnumerator : NSEnumerator

- (id)initWithSequence:(id<PBTSequence>)sequence;

@property (nonatomic) id<PBTSequence> sequence;

@end

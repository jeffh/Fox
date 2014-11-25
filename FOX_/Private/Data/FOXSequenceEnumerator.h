#import "FOXSequence.h"


@interface FOXSequenceEnumerator : NSEnumerator

- (id)initWithSequence:(id<FOXSequence>)sequence;

@property (nonatomic) id<FOXSequence> sequence;

@end

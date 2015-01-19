#import "FOXRandom.h"
#import "FOXSequence.h"

@interface FOXSequenceRandom : NSObject <FOXRandom>

- (instancetype)initWithSequence:(id<FOXSequence>)sequence;

@end

@interface FOXSequence (SequenceRandom)

+ (instancetype)lazySequenceFromRandom:(id<FOXRandom>)random;

@end

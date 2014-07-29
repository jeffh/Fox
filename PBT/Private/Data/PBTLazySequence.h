#import "PBTSequence.h"


typedef id<PBTSequence>(^PBTLazySequenceBlock)();

@interface PBTLazySequence : PBTSequence

- (instancetype)init;
- (instancetype)initWithLazyBlock:(PBTLazySequenceBlock)block;

@end

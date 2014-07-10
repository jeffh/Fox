#import "PBTSequence.h"
#import "PBTAbstractSequence.h"


typedef id<PBTSequence>(^PBTLazySequenceBlock)();

@interface PBTLazySequence : PBTAbstractSequence

- (instancetype)init;
- (instancetype)initWithLazyBlock:(PBTLazySequenceBlock)block;

@end

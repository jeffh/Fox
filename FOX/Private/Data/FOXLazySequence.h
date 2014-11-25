#import "FOXSequence.h"


typedef id<FOXSequence>(^FOXLazySequenceBlock)();

@interface FOXLazySequence : FOXSequence

- (instancetype)init;
- (instancetype)initWithLazyBlock:(FOXLazySequenceBlock)block;

@end

#import <Foundation/Foundation.h>
#import "PBTSequence.h"

typedef id<PBTSequence>(^PBTLazySequenceBlock)();

@interface PBTLazySequence : NSObject <PBTSequence>

- (instancetype)init;
- (instancetype)initWithLazyBlock:(PBTLazySequenceBlock)block;

@end

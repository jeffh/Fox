#import <Foundation/Foundation.h>
#import "PBTSequence.h"


@interface PBTConcreteSequence : NSObject <PBTSequence>

- (instancetype)init;
- (instancetype)initWithObject:(id)object;
- (instancetype)initWithObject:(id)object
             remainingSequence:(id<PBTSequence>)sequence;

@end

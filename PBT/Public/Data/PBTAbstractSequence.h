#import <Foundation/Foundation.h>
#import "PBTSequence.h"

// subclasses must implement these public methods.
// the abstract class will provide convience methods.
@interface PBTAbstractSequence : NSObject <PBTSequence>

- (id)firstObject;
- (id<PBTSequence>)remainingSequence;

@end

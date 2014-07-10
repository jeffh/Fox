#import <Foundation/Foundation.h>
#import "PBTSequence.h"

// subclasses must conform to the PBTSequence protocol.
// the abstract class will provide convience methods.
@interface PBTAbstractSequence : NSObject <PBTSequence>
@end

#import "PBTQuickCheck.h"

@interface PBTDebugReporter : NSObject <PBTQuickCheckReporter>

- (instancetype)init;
- (instancetype)initWithFile:(FILE *)file;

@end

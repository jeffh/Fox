#import "PBTRunner.h"

@interface PBTDebugReporter : NSObject <PBTReporter>

- (instancetype)init;
- (instancetype)initWithFile:(FILE *)file;

@end

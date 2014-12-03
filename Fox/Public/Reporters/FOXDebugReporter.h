#import "FOXRunner.h"
#import "FOXReporter.h"

@interface FOXDebugReporter : NSObject <FOXReporter>

- (instancetype)init;
- (instancetype)initWithFile:(FILE *)file;

@end

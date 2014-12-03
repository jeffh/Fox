#import "FOXRunner.h"
#import "FOXReporter.h"


@interface FOXStandardReporter : NSObject <FOXReporter>

- (instancetype)init;
- (instancetype)initWithFile:(FILE *)file;

@end

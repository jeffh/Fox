#import "PBTQuickCheck.h"

@interface PBTQuickCheckPrinter : NSObject <PBTQuickCheckReporter>

- (instancetype)init;
- (instancetype)initWithFile:(FILE *)file;

@end

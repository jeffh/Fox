#import "PBTQuickCheck.h"

@interface PBTStandardReporter : NSObject <PBTQuickCheckReporter>

- (instancetype)init;
- (instancetype)initWithFile:(FILE *)file;

@end

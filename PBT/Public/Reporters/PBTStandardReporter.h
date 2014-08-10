#import "PBTRunner.h"


@interface PBTStandardReporter : NSObject <PBTReporter>

- (instancetype)init;
- (instancetype)initWithFile:(FILE *)file;

@end

#import "FOXMacros.h"

@protocol FOXRandom;

FOX_ALPHA_API
@interface FOXScheduler : NSObject

- (instancetype)initWithRandom:(id<FOXRandom>)random;
- (instancetype)initWithRandom:(id<FOXRandom>)random
        replaceSystemFunctions:(BOOL)replaceThreads;
- (void)runAndWait:(void(^)())block;

@end

FOX_ALPHA_API
FOX_EXPORT void FOXSchedulerYield(void);

#import <Foundation/Foundation.h>

@protocol FOXRandom;

@interface FOXScheduler : NSObject

- (instancetype)initWithRandom:(id<FOXRandom>)random;
- (instancetype)initWithRandom:(id<FOXRandom>)random replaceThreads:(BOOL)replaceThreads;
- (void)runAndWait:(void(^)())block;

@end

#import <Foundation/Foundation.h>

@interface Ticker : NSObject

- (NSInteger)increment;
- (void)reset;

- (NSInteger)atomicIncrement;
- (void)atomicReset;

- (NSInteger)incrementWithManualInstrumentation;
- (void)resetWithManualInstrumentation;

@end

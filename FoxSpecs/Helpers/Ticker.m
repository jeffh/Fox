#import "Ticker.h"
#import <libkern/OSAtomic.h>
#import "FOXFiber.h"

@interface Ticker ()
@property (nonatomic) NSInteger count;
@end

@implementation Ticker {
    OSSpinLock _lock;
}

- (NSInteger)increment
{
    return ++self.count;
}

- (void)reset
{
    self.count = 0;
}

- (NSInteger)atomicIncrement
{
    OSSpinLockLock(&_lock);
    NSInteger result = [self increment];
    OSSpinLockUnlock(&_lock);
    return result;
}

- (void)atomicReset
{
    OSSpinLockLock(&_lock);
    [self reset];
    OSSpinLockUnlock(&_lock);
}

- (NSInteger)incrementWithManualInstrumentation
{
    FOXFiberYield(NULL);
    NSInteger count = self.count;
    FOXFiberYield(NULL);
    count++;
    FOXFiberYield(NULL);
    self.count = count;
    FOXFiberYield(NULL);
    return count;
}

- (void)resetWithManualInstrumentation
{
    FOXFiberYield(NULL);
    self.count = 0;
}

@end

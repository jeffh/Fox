#import "Ticker.h"
#import <libkern/OSAtomic.h>
#import "FOXThread.h"

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

- (NSInteger)incrementWithInstanceVariable
{
    return ++_count;
}

- (void)resetWithInstanceVariable
{
    _count = 0;
}

- (NSInteger)incrementMoreComplicatedThanNeeded
{
#define NEW(A) [[A alloc] init]
    NSMutableArray *numbers = NEW(NSMutableArray);
    for (NSInteger i = 0; i < self.count; i++) {
        [numbers addObject:@(self.count - i)];
    }
    [numbers insertObject:@([numbers[0] integerValue] + 1) atIndex:0];
    return [numbers.lastObject integerValue];
#undef NEW
}

- (NSInteger)atomicIncrement
{
    OSSpinLockLock(&_lock);
    NSInteger result = [self incrementWithManualInstrumentation];
    OSSpinLockUnlock(&_lock);
    return result;
}

- (void)atomicReset
{
    OSSpinLockLock(&_lock);
    [self resetWithManualInstrumentation];
    OSSpinLockUnlock(&_lock);
}

- (NSInteger)incrementWithManualInstrumentation
{
    fthread_yield();
    NSInteger count = self.count;
    fthread_yield();
    count++;
    fthread_yield();
    self.count = count;
    fthread_yield();
    return count;
}

- (void)resetWithManualInstrumentation
{
    fthread_yield();
    self.count = 0;
}

@end

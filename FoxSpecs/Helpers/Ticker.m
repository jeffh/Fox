#import "Ticker.h"
#import <libkern/OSAtomic.h>

@interface Ticker ()
@property (nonatomic) NSInteger count;
@end

@implementation Ticker {
    OSSpinLock _lock;
}

- (NSInteger)increment {
    return ++self.count;
}

- (void)reset {
    self.count = 0;
}

- (NSInteger)atomicIncrement {
    OSSpinLockLock(&_lock);
    NSInteger result = [self increment];
    OSSpinLockUnlock(&_lock);
    return result;
}

- (void)atomicReset {
    OSSpinLockLock(&_lock);
    [self reset];
    OSSpinLockUnlock(&_lock);
}

@end

#import "FOXInstrumentation.h"
#import <libkern/OSAtomic.h>

static struct {
    OSSpinLock lock;
    BOOL isInstrumented;
} __foxInstrumentation;

FOX_EXPORT BOOL FOXIsInstrumented(void) {
    OSSpinLockLock(&__foxInstrumentation.lock);
    BOOL isInstrumented = __foxInstrumentation.isInstrumented;
    OSSpinLockUnlock(&__foxInstrumentation.lock);

    return isInstrumented;
}

FOX_EXPORT void FOXSetInstrumentation(BOOL enable) {
    OSSpinLockLock(&__foxInstrumentation.lock);
    __foxInstrumentation.isInstrumented = enable;
    OSSpinLockUnlock(&__foxInstrumentation.lock);
}

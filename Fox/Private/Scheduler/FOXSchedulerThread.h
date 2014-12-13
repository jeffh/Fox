#import "FOXMacros.h"

typedef NS_ENUM(NSUInteger, FOXSchedulerThreadState) {
    FOXSchedulerThreadStateRunnable,
    FOXSchedulerThreadStateRunning,
    FOXSchedulerThreadStateCompleted,
};

typedef struct _FOXSchedulerThread *FOXSchedulerThreadPtr;

FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerThreadCreate(unsigned int number, dispatch_group_t yield);
FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerThreadCreateWithQueue(unsigned int number, dispatch_group_t yield, dispatch_queue_t queue);

FOX_EXPORT void FOXSchedulerThreadRelease(FOXSchedulerThreadPtr thread);

FOX_EXPORT void FOXSchedulerThreadEnqueue(FOXSchedulerThreadPtr thread, void (^action)());
FOX_EXPORT void FOXSchedulerThreadEnqueueExit(FOXSchedulerThreadPtr thread);

FOX_EXPORT void FOXSchedulerThreadSetData(FOXSchedulerThreadPtr thread, void *data, void (*freer)(void *data));
FOX_EXPORT void *FOXSchedulerThreadGetData(FOXSchedulerThreadPtr thread);

/// Yield assumes its running on the given thread
FOX_EXPORT void FOXSchedulerThreadYield(FOXSchedulerThreadPtr thread);

// expected to run on another thread
FOX_EXPORT void FOXSchedulerThreadResume(FOXSchedulerThreadPtr thread);
// expected to run on another thread
FOX_EXPORT void FOXSchedulerThreadWaitForYield(FOXSchedulerThreadPtr thread);

// reading thread state
FOX_EXPORT dispatch_queue_t FOXSchedulerThreadGetDispatchQueue(FOXSchedulerThreadPtr thread);
FOX_EXPORT unsigned int FOXSchedulerThreadGetNumber(FOXSchedulerThreadPtr thread);
FOX_EXPORT bool FOXSchedulerThreadCompleted(FOXSchedulerThreadPtr thread);


#import "FOXSchedulerThread.h"
#import <libkern/OSAtomic.h>
#import <dispatch/dispatch.h>

typedef struct _FOXSchedulerThread {
    // -- safe to modify anywhere
    dispatch_group_t yield; // leave to signal yielding
    dispatch_semaphore_t unpause; // wait on this to "pause"
    dispatch_queue_t queue;

    // -- only should be modified in-thread
    volatile unsigned int number;
    volatile FOXSchedulerThreadState state;

    // -- attached state
    void *data;
    void (*freer)(void *data);
} *FOXSchedulerThreadPtr;

__thread FOXSchedulerThreadPtr currentThread;

FOX_INLINE FOXSchedulerThreadPtr threadOrCurrentThread(FOXSchedulerThreadPtr t) {
    if (t) {
        return t;
    }
    if (currentThread) {
        return currentThread;
    }

    NSCAssert(NO, @"Could not find scheduler thread. Not executing inside a scheduler thread.");
    return nil;
}

FOX_EXPORT unsigned int FOXSchedulerThreadGetNumber(FOXSchedulerThreadPtr thread) {
    return thread->number;
}

FOX_EXPORT bool FOXSchedulerThreadCompleted(FOXSchedulerThreadPtr thread) {
    return thread->state == FOXSchedulerThreadStateCompleted;
}

FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerThreadCreate(unsigned int number, dispatch_group_t yield) {
    char *name = (char *)alloca(sizeof(char) * 35);
    sprintf(name, "net.jeffhui.fox.scheduler.thread.%u", number);
    dispatch_queue_t queue = dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL);
    return FOXSchedulerThreadCreateWithQueue(number, yield, queue);
}

FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerThreadCreateWithQueue(unsigned int number, dispatch_group_t yield, dispatch_queue_t queue) {
    FOXSchedulerThreadPtr thread = (FOXSchedulerThreadPtr)calloc(sizeof(struct _FOXSchedulerThread), 1);
    thread->number = number;
    thread->yield = yield;
    thread->unpause = dispatch_semaphore_create(0);
    thread->queue = queue;
    return thread;
}

FOX_EXPORT void FOXSchedulerThreadRelease(FOXSchedulerThreadPtr thread) {
    FOXSchedulerThreadSetData(thread, NULL, NULL);
    dispatch_release(thread->unpause);
    dispatch_release(thread->queue);
    free(thread);
}

FOX_EXPORT void FOXSchedulerThreadStep(FOXSchedulerThreadPtr thread, void (^action)()) {
    currentThread = thread;
    printf("[Thread %u]: Paused\n", thread->number);
    dispatch_semaphore_wait(thread->unpause, DISPATCH_TIME_FOREVER);
    assert(thread->state != FOXSchedulerThreadStateCompleted);

    printf("[Thread %u]: Running\n", thread->number);
    if (thread->state == FOXSchedulerThreadStateRunnable) {
        thread->state = FOXSchedulerThreadStateRunning;
        OSMemoryBarrier();
    }
    action();
    dispatch_group_leave(thread->yield);
}

FOX_EXPORT void FOXSchedulerThreadEnqueue(FOXSchedulerThreadPtr thread, void (^action)()) {
    dispatch_async(thread->queue, ^{
        FOXSchedulerThreadStep(thread, action);
    });
}

FOX_EXPORT void FOXSchedulerThreadEnqueueExit(FOXSchedulerThreadPtr thread) {
    thread = threadOrCurrentThread(thread);
    dispatch_async(thread->queue, ^{
        thread->state = FOXSchedulerThreadStateCompleted;
    });
}

FOX_EXPORT void FOXSchedulerThreadYield(FOXSchedulerThreadPtr thread) {
    thread = threadOrCurrentThread(thread);
    dispatch_group_leave(thread->yield);
    dispatch_semaphore_wait(thread->unpause, DISPATCH_TIME_FOREVER);
}

FOX_EXPORT void FOXSchedulerThreadResume(FOXSchedulerThreadPtr thread) {
    dispatch_semaphore_signal(thread->unpause);
}

FOX_EXPORT dispatch_queue_t FOXSchedulerThreadGetDispatchQueue(FOXSchedulerThreadPtr thread) {
    return thread->queue;
}

FOX_EXPORT void FOXSchedulerThreadSetData(FOXSchedulerThreadPtr thread, void *data, void (*freer)(void *data)) {
    void (*freeData)(void *) = thread->freer;
    void *oldData = thread->data;
    thread->data = data;
    thread->freer = freer;
    if (freeData != NULL) {
        (*freeData)(oldData);
    }
}

FOX_EXPORT void *FOXSchedulerThreadGetData(FOXSchedulerThreadPtr thread) {
    return thread->data;
}

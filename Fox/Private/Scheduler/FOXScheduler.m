#import "FOXScheduler.h"
#import "FOXRandom.h"
#import "FOXDeterministicRandom.h"
#import "FOXInstrumentation.h"
#import <assert.h>
#import <string.h>
#import <libkern/OSAtomic.h>

typedef struct _FOXScheduler {
    // these should never change after construction
    void (*algorithm)(FOXSchedulerPtr scheduler);
    id<FOXRandom> random;
    dispatch_group_t yielder;

    // use lock to mutate these properties
    OSSpinLock lock;
    unsigned int numberOfThreads;
    unsigned int threadsCapacity;
    FOXSchedulerThreadPtr *threads;
} FOXScheduler, *FOXSchedulerPtr;

#pragma mark - Private

FOX_INLINE void _FOXSchedulerAcquireLock(FOXSchedulerPtr s) {
    OSSpinLockLock(&s->lock);
}

FOX_INLINE void _FOXSchedulerReleaseLock(FOXSchedulerPtr s) {
    OSSpinLockUnlock(&s->lock);
}

FOX_EXPORT void FOXSchedulerWaitForThread(FOXSchedulerPtr s, void(^block)()) {
    dispatch_group_enter(s->yielder);
    block();
    dispatch_group_wait(s->yielder, DISPATCH_TIME_FOREVER);
}

FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerAddSchedulerThreadUnsafe(FOXSchedulerPtr s) {
    FOXSchedulerThreadPtr thread = FOXSchedulerThreadCreate(s->numberOfThreads, s->yielder);
    if (s->threadsCapacity >= s->numberOfThreads) {
        s->threads = (FOXSchedulerThreadPtr *)realloc(s->threads, s->threadsCapacity * 2 + 4);
        s->threadsCapacity = s->threadsCapacity * 2 + 4;
    }
    s->threads[s->numberOfThreads] = thread;
    s->numberOfThreads++;
    return thread;
}

FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerGetThreadForQueueUnsafe(FOXSchedulerPtr s, dispatch_queue_t queue) {
    for (unsigned int i = 0; i < s->numberOfThreads; i++) {
        FOXSchedulerThreadPtr t = s->threads[i];
        if (FOXSchedulerThreadGetDispatchQueue(t) == queue) {
            return t;
        }
    }
    return NULL;
}

FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerFindOrAddThreadForQueueUnsafe(FOXSchedulerPtr s, dispatch_queue_t queue) {
    FOXSchedulerThreadPtr thread = FOXSchedulerGetThreadForQueueUnsafe(s, queue);
    if (!thread) {
        thread = FOXSchedulerAddSchedulerThreadUnsafe(s);
    }
    return thread;
}

#pragma mark - Public

FOX_EXPORT FOXSchedulerPtr FOXSchedulerCreate(id<FOXRandom> random) {
    return FOXSchedulerCreateWithAlgorithm(random, &FOXRandomScheduling);
}

FOX_EXPORT FOXSchedulerPtr FOXSchedulerCreateWithAlgorithm(id<FOXRandom> random, void (*algorithm)(FOXSchedulerPtr s)) {
    FOXSchedulerPtr s = (FOXSchedulerPtr)calloc(sizeof(FOXScheduler), 1);
    s->algorithm = FOXNaiveScheduling;
    s->numberOfThreads = 0;
    s->threadsCapacity = 0;
    s->algorithm = algorithm;
    s->yielder = dispatch_group_create();
    s->random = [random retain] ?: [[FOXDeterministicRandom alloc] init];
    return s;
}

FOX_EXPORT void FOXSchedulerRelease(FOXSchedulerPtr s) {
    _FOXSchedulerAcquireLock(s);
    for (unsigned int i = 0; i < s->numberOfThreads; i++) {
        FOXSchedulerThreadRelease(s->threads[i]);
    }
    [s->random release];
    dispatch_release(s->yielder);
    free(s->threads);
    free(s);
}

FOX_EXPORT void FOXSchedulerStart(FOXSchedulerPtr s, void(^block)()) {
    _FOXSchedulerAcquireLock(s);
    block();
    (*s->algorithm)(s);
    _FOXSchedulerReleaseLock(s);
}

FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerAddSchedulerThread(FOXSchedulerPtr s) {
    _FOXSchedulerAcquireLock(s);
    FOXSchedulerThreadPtr thread = FOXSchedulerAddSchedulerThreadUnsafe(s);
    _FOXSchedulerReleaseLock(s);
    return thread;
}

FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerGetThreadForQueue(FOXSchedulerPtr s, dispatch_queue_t queue) {
    _FOXSchedulerAcquireLock(s);
    FOXSchedulerThreadPtr thread = FOXSchedulerGetThreadForQueueUnsafe(s, queue);
    _FOXSchedulerReleaseLock(s);
    return thread;
}

FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerGetOrAddThreadForQueue(FOXSchedulerPtr s, dispatch_queue_t queue) {
    _FOXSchedulerAcquireLock(s);
    FOXSchedulerThreadPtr thread = FOXSchedulerGetOrAddThreadForQueue(s, queue);
    _FOXSchedulerReleaseLock(s);
    return thread;
}

FOX_EXPORT void FOXSchedulerYield(void) {
    FOXSchedulerThreadYield(NULL);
}

FOX_EXPORT void FOXSchedulerYieldOnQueue(FOXSchedulerPtr s, dispatch_queue_t queue) {
    _FOXSchedulerAcquireLock(s);
    FOXSchedulerThreadPtr thread = FOXSchedulerFindOrAddThreadForQueueUnsafe(s, queue);
    _FOXSchedulerReleaseLock(s);
    dispatch_barrier_async(queue, ^{
        FOXSchedulerThreadYield(thread);
    });
}

void _FOXSchedulerMsgSendHandler(id target, SEL selector) {
    FOXSchedulerYield();
}

FOX_EXPORT void FOXSchedulerInstrument(FOXSchedulerPtr s, void(^block)()) {
    FOXOverrideMsgSend(&_FOXSchedulerMsgSendHandler);
}

#pragma mark - Scheduling Algorithms

FOX_EXPORT void FOXRandomScheduling(FOXSchedulerPtr scheduler) {
    bool processedAThread = YES;
    while (processedAThread && scheduler->numberOfThreads) {
        processedAThread = NO;
        long long max = scheduler->numberOfThreads - 1;
        long long index = [scheduler->random randomIntegerWithinMinimum:0
                                                             andMaximum:max];
        FOXSchedulerThreadPtr t = scheduler->threads[index];
        if (!FOXSchedulerThreadCompleted(t)) {
            printf("Schedule Thread %u\n", FOXSchedulerThreadGetNumber(t));
            processedAThread = YES;
            FOXSchedulerWaitForThread(scheduler, ^{
                FOXSchedulerThreadResume(t);
            });
        } else {
            for (unsigned int i = 0; i < scheduler->numberOfThreads; i++) {
                t = scheduler->threads[i];
                if (!FOXSchedulerThreadCompleted(t)) {
                    printf("Schedule Thread %u\n", FOXSchedulerThreadGetNumber(t));
                    processedAThread = YES;
                    FOXSchedulerWaitForThread(scheduler, ^{
                        FOXSchedulerThreadResume(t);
                    });
                }
            }
        }
    }
}

FOX_EXPORT void FOXNaiveScheduling(FOXSchedulerPtr scheduler) {
    for (unsigned int i = 0; i < scheduler->numberOfThreads; i++) {
        FOXSchedulerThreadPtr t = scheduler->threads[i];
        while (!FOXSchedulerThreadCompleted(t)) {
            FOXSchedulerThreadResume(t);
        }
    }
}

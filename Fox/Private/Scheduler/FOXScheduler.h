#import "FOXMacros.h"
#import "FOXSchedulerThread.h"
#import <dispatch/dispatch.h>

@protocol FOXRandom;

/// A user-level cooperative scheduler.
///
/// The scheduler is specifically written in C to avoid FOXInstrumentation
/// from instrumenting the scheduler.

typedef struct _FOXScheduler *FOXSchedulerPtr;

/// Creates a scheduler with a random number generator.
FOX_EXPORT FOXSchedulerPtr FOXSchedulerCreate(id<FOXRandom> random);

/// Creates a scheduler with a random number generator and scheduling
/// algorithm.
FOX_EXPORT FOXSchedulerPtr FOXSchedulerCreateWithAlgorithm(id<FOXRandom> random, void (*algorithm)(FOXSchedulerPtr s));
FOX_EXPORT void FOXSchedulerRelease(FOXSchedulerPtr scheduler);

/// Creates and adds a logical thread to the scheduler. A logical thread
/// models parallel work that can be done for the scheduler to order.
FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerAddSchedulerThread(FOXSchedulerPtr s);

FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerGetThreadForQueue(FOXSchedulerPtr s, dispatch_queue_t queue);
FOX_EXPORT FOXSchedulerThreadPtr FOXSchedulerGetOrAddThreadForQueue(FOXSchedulerPtr s, dispatch_queue_t queue);

/// Starts the scheduler. The provided block is invoked to trigger
/// the spawning of threads. Do not assume the block may be executed
/// on the main thread.
FOX_EXPORT void FOXSchedulerStart(FOXSchedulerPtr s, void(^block)());

/// Used in a logical thread to yield the control flow back to the scheduler.
/// Will abort if yielding on a thread the scheduler does not recognize.
FOX_EXPORT void FOXSchedulerYield(void);
/// Used to yield the control flow back to the scheduler. It can be given
/// a queue that the scheduler does not recognize.
///
/// Warning: this is less reliable to hijack a queue not owned by the
///          scheduler.
FOX_EXPORT void FOXSchedulerYieldOnQueue(FOXSchedulerPtr s, dispatch_queue_t queue);

/// Executes a given block and reinstruments it to be cooperative.
FOX_EXPORT void FOXSchedulerInstrument(FOXSchedulerPtr s, void(^block)());

#pragma mark Scheduling Algorithms

FOX_EXPORT void FOXRandomScheduling(FOXSchedulerPtr scheduler);
FOX_EXPORT void FOXNaiveScheduling(FOXSchedulerPtr scheduler);

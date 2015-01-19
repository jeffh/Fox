/// Cooperative scheduling in a pthreads-like API

#import "FOXMacros.h"
#import <pthread/pthread.h>
#import <semaphore.h>
#import <mach/mach.h>
#import <libkern/OSAtomic.h>

// code style: snake case for this file to be more POSIX-styled

#pragma mark - Fox Extensions

/*! An opaque type representing Fox's pthread representation.
 *
 *  This can be used with other fox-specific functions instead of using
 *  pthread_t. It is NOT safe to cast pthread_t to this type.
 */
typedef void *fthread_t;

/*! An opaque type representing the scheduling algorithm to use.
 *  Some algorithms may require additional data passed to fthread_run_and_wait.
 */
typedef void *fthread_schedule_algorithm_t;

/*! A fair scheduling algorithm where each thread, in order of creation, gets
 *  the same number of unyields to each thread for execute.
 *
 *  Requires no additional algorithm data.
 */
fthread_schedule_algorithm_t fthread_round_robin;

/*! An unfair scheduling algorithm where each thread randomly gets unyields to
 *  execute.
 *
 *  Requires a FOXRandom instance as additional algorithm data.
 */
fthread_schedule_algorithm_t fthread_random;


fthread_schedule_algorithm_t fthread_random_unblocked;

/*! Yields the current thread so another thread can execute.
 */
FOX_EXPORT void fthread_yield(void);

/*! Initializes the global scheduler. You must call this before creating
 *  any threads to ensure they can be properly scheduled for execution.
 *
 *  Also, this can be used to reset the scheduler to setup an new execution.
 */
FOX_EXPORT void fthread_init(void);

/*! Runs the threads awaiting execution until they finish.
 */
FOX_EXPORT void fthread_run_and_wait(fthread_schedule_algorithm_t algo,
                                     void *algo_data);

void fthread_run(fthread_schedule_algorithm_t algo, void *algo_data);
void fthread_wait(void);

/*! Replaces the normal functions with ones fox provides. See below to see the
 *  overridden functions. Implementation is currently in flux and can change at
 *  anytime.
 *
 *  Implementation of this function is subject to change,
 *  and is currently NOT safe to call for actual iOS devices.
 *
 *  Once called, overriden functions PERMANENTLY MODIFIED. The bool argument
 *  indicates if the fox code is used or the original function implementation
 *  is emulated (by calling through to the original implementation). While
 *  technically identical when the bool is false, this can behave slightly
 *  differently for concurrent applications due to not having the exact idential
 *  assembly instructions in comparison to never calling this function.
 *
 *  For more details on how this works, see mach_override.
 *
 *  @warning this function is not thread safe. You should only call this
 *           prior to using threads.
 */
FOX_EXPORT void fthread_override(bool replace);

/*! Returns the current fthread for the running thread. Returns NULL if
 *  fox is not tracking the current thread.
 *
 *  @returns the current fthread_t for this thread. Or NULL if there isn't one.
 */
FOX_EXPORT fthread_t fthread_current(void);

/*! Returns the current fthread fox is using to track the given pthread.
 *  Returns NULL if fox is not tracking the current thread.
 *
 *  @param pthread The pthread_t representation of the fthread_t to get.
 *  @returns The fthread_t associated to the given pthread_t. Or NULL if there
 *           isn't one.
 */
FOX_EXPORT fthread_t fthread_get(pthread_t pthread);

/*! Unyields the given thread so it can execute.
 */
FOX_EXPORT void fthread_unyield(fthread_t fthread);

/*! Makes the current thread block until the given thread yields. This is
 *  rarely used since fthread_run_and_wait() does this internally.
 *
 *  @param fthread The thread to wait until it yields via fthread_yield().
 */
FOX_EXPORT void fthread_waitfor(fthread_t fthread);

// The following functions can change at anytime to comply to the the functions
// they replace. This is to ensure they are ABI compatible with the system
// provided implementations.

#pragma mark - POSIX Threads

FOX_EXPORT int fthread_create(pthread_t *thread,
                              pthread_attr_t *attr,
                              void *(*thread_main)(void *),
                              void *thread_data);
FOX_EXPORT int fthread_detach(pthread_t thread);
FOX_EXPORT void fthread_exit(void *);
FOX_EXPORT int fthread_join(pthread_t, void **);

#pragma mark Mutex

FOX_EXPORT int fthread_mutex_lock(pthread_mutex_t *mutex);

#pragma mark Conditional Variables

FOX_EXPORT int fthread_cond_timedwait(pthread_cond_t *cond,
                                      pthread_mutex_t *mutex,
                                      const struct timespec *timespec);
FOX_EXPORT int fthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex);

#pragma mark - POSIX Semaphores

FOX_EXPORT int fox_sem_wait(sem_t *sem);

#pragma mark - Mach Semaphores

FOX_EXPORT kern_return_t fox_semaphore_wait(semaphore_t semaphore);
FOX_EXPORT kern_return_t fox_semaphore_timedwait(semaphore_t semaphore,
                                                 mach_timespec_t wait_time);

// not supported...yet
//kern_return_t fox_semaphore_timedwait_signal(semaphore_t wait_semaphore,
//                                             semaphore_t signal_semaphore,
//                                             mach_timespec_t wait_time);
//
//kern_return_t fox_semaphore_wait_signal(semaphore_t wait_semaphore,
//                                        semaphore_t signal_semaphore);
//
//kern_return_t fox_semaphore_signal_thread(semaphore_t semaphore,
//                                          thread_t thread);

#pragma mark - OSSpinLocks

FOX_EXPORT void fox_spinlock_lock(volatile OSSpinLock *lock);

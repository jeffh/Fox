/// Cooperative scheduling in a pthreads-like API

#import "FOXMacros.h"
#import <pthread/pthread.h>
#import <semaphore.h>
#import <mach/mach.h>
#import <libkern/OSAtomic.h>

// code style: Matching POSIX style that what's it replaces

#pragma mark - Fox Extensions

/*! An opaque type representing Fox's pthread representation.
 *
 *  This can be used with other fox-specific functions instead of using
 *  pthread_t.
 */
typedef void *fthread_t;

/*! Yields the current thread so another thread can execute.
 */
void fthread_yield(void);

/*! Initializes the global scheduler. You must call this before creating
 *  any threads to ensure they can be properly scheduled for execution.
 *
 *  Also, this can be used to reset the scheduler to setup an new execution.
 */
void fthread_init(void);

/*! Runs the threads awaiting execution until they finish.
 */
void fthread_run_and_wait(void);

/*! Replaces the normal functions with ones fox provides. See below to see the
 *  overridden functions. Implementation is currently in flux and can change at
 *  anytime.
 *
 *  Implementation of this function is subject to chain in significant behavior,
 *  and is NOT safe to call for actual iOS devices.
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
void fthread_override(bool replace);

/*! Returns the current fthread for the running thread. Returns NULL if
 *  fox is not tracking the current thread.
 *
 *  @returns the current fthread_t for this thread. Or NULL if there isn't one.
 */
fthread_t fthread_current(void);

/*! Returns the current fthread fox is using to track the given pthread.
 *  Returns NULL if fox is not tracking the current thread.
 *
 *  @param pthread The pthread_t representation of the fthread_t to get.
 *  @returns The fthread_t associated to the given pthread_t. Or NULL if there
 *           isn't one.
 */
fthread_t fthread_get(pthread_t pthread);

/*! Unyields the given thread so it can execute.
 */
void fthread_unyield(fthread_t fthread);

/*! Makes the current thread block until the given thread yields. This is
 *  rarely used since fthread_run_and_wait() does this internally.
 *
 *  @param fthread The thread to wait until it yields via fthread_yield().
 */
void fthread_waitfor(fthread_t fthread);

// The following functions can change at anytime to comply to the the functions
// they replace. This is to ensure they are ABI compatible with the system
// provided implementations.

#pragma mark - POSIX Threads

int fthread_create(pthread_t *thread,
                   pthread_attr_t *attr,
                   void *(*thread_main)(void *),
                   void *thread_data);
int fthread_detach(pthread_t thread);
void fthread_exit(void *);
int fthread_join(pthread_t, void **);

#pragma mark Mutex

int fthread_mutex_lock(pthread_mutex_t *mutex);

#pragma mark Conditional Variables

int fthread_cond_timedwait(pthread_cond_t *cond,
                           pthread_mutex_t *mutex,
                           const struct timespec *timespec);
int fthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex);

#pragma mark - POSIX Semaphores

int fox_sem_wait(sem_t *sem);

#pragma mark - Mach Semaphores

kern_return_t fox_semaphore_wait(semaphore_t semaphore);
kern_return_t fox_semaphore_timedwait(semaphore_t semaphore,
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

void fox_spinlock_lock(volatile OSSpinLock *lock);

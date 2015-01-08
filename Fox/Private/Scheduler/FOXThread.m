#import "FOXThread.h"
#import <stdio.h>
#import <time.h>
#import "mach_override.h"
#import "FOXMemory.h"
#import "FOXThreadMachine.h"
#import "FOXRandom.h"

// Implementation Note:
// At the time of writing of this note, low-level implementations are as
// follows:
//
//  - libdispatch uses either mach features and/or pthread features
//  - pthreads uses mach features
//
// This makes libdispatch unsafe to use in this library. pthread APIs can be
// used if they are not being overridden, but they should all be abstracted to
// the fthread_machine interface

// When defined, this macro will enable debug logging of the scheduler.
// Note: Enabling this will DISABLE fox's hook into pthread mutex locks.
// uncomment this when debugging, but leave this commented when committing.
//#define FOX_LOG_THREADS

#ifdef FOX_LOG_THREADS
#   define FTHREAD_DEBUG(...) printf(__VA_ARGS__)
#else
#   define FTHREAD_DEBUG(...)
#endif

// a short-hand to type-casting to the function type pthreads expects
#define THREAD_FN(fn) ((void *(*)(void *))(fn))

// locks fthread / scheduler locks
#define MUTEX_LOCK(M) get_machine()->spinlock_lock((M))
// unlocks a fthread / scheduler locks
#define MUTEX_UNLOCK(M) get_machine()->spinlock_unlock((M))

/// Represents a posix thread
typedef struct __fthread {
    // thread-safe, read-only fields
    pthread_t pthread;
    char *name;
    semaphore_t signal_to_unyield;
    semaphore_t signal_to_yield;

    // rw-lock fields
    OSSpinLock state_lock;
    bool is_detached;
    bool is_finished;
    bool is_not_first_call;

    // read-only fields
    void *(*user_main)(void *);
    void *user_data;
} *fthread_internal_t;

/// Represents the scheduler's data for managing thread execution
/// The actual thread scheduling is done on the worker_thread for ease of
/// implementation.
typedef struct _fthread_scheduler_t {
    // rw-lock fields
    OSSpinLock lock;
    fthread_internal_t worker_thread;
    fthread_internal_t *threads;
    unsigned int num_threads;
    unsigned int capacity;
    unsigned int next_thread_number;
    void (*algorithm)(struct _fthread_scheduler_t *);
    void *algorithm_data;
} fthread_scheduler_t;

// A boolean to indicate if we have mach_overridden lib functions
// not thread-safe.
static volatile bool __has_overridden_functions;
// A boolean to indicate if we need to "disable" the custom implementations
// not thread-safe.
static volatile bool __use_fox_implementation;

// pthread key to indicate the current fthread_internal_t
pthread_key_t current_fthread_key;
pthread_once_t current_fthread_once;

// global scheduler. This is global to easily allow threads to yield control
// and derive their names from the scheduler's known thread count.
static fthread_scheduler_t __scheduler = {
    .lock               = 0,
    .threads            = NULL,
    .worker_thread      = NULL,
    .num_threads        = 0,
    .capacity           = 0,
    .next_thread_number = 0,
};

#pragma mark - Private Function Prototypes

static int fthread_scheduler_create(fthread_internal_t *fthread_ptr,
                                    void *(*thread_main)(void *),
                                    void *thread_data);
static bool fthread_is_complete(fthread_internal_t fthread);
static void fthread_yield_thread(fthread_internal_t fthread);
static void fthread_free(fthread_internal_t fthread);

#pragma mark - Helper Functions

static void must(int result, char *error_msg) {
    if (result) {
        fprintf(stderr, "%s\n", error_msg);
        exit(2);
    }
}

static kern_return_t retry_if_aborted(semaphore_t s, kern_return_t(*action)(semaphore_t)) {
    kern_return_t result = 0;
    do {
        result = action(s);
    } while (result == KERN_ABORTED);
    return result;
}

static kern_return_t semaphore_signal_without_aborting(semaphore_t s) {
    return retry_if_aborted(s, get_machine()->semaphore_signal);
}

static kern_return_t semaphore_wait_without_aborting(semaphore_t s) {
    return retry_if_aborted(s, get_machine()->semaphore_wait);
}

static void _semaphore_create(semaphore_t *s) {
    kern_return_t err = get_machine()->semaphore_create(mach_task_self(), s, SYNC_POLICY_FIFO, 0);
    if (err) {
        fprintf(stderr, "Failed to create semaphore: %d\n", err);
        abort();
    }
}

#pragma mark - Global State Management

static void create_fthread_key(void) {
    get_machine()->thread_key_create(&current_fthread_key, NULL);
}

/*! Returns the current fthread_internal_t for the given thread. Can be
 *  NULL if fox is not currently tracking the given thread.
 *
 *  Note: The main thread WILL return a value (for debugging purposes), but
 *        only its name field is valid.
 */
static fthread_internal_t get_current_thread(void) {
    if (current_fthread_key == 0) {
        return NULL;
    }
    return pthread_getspecific(current_fthread_key);
}

static void set_current_thread(fthread_internal_t current_thread) {
    pthread_setspecific(current_fthread_key, current_thread);
}

/*! Atomically increments and returns an integer from the global scheduler.
 *  Useful for naming threads.
 */
unsigned int next_thread_number(void) {
    MUTEX_LOCK(&__scheduler.lock);
    unsigned int num = ++__scheduler.next_thread_number;
    MUTEX_UNLOCK(&__scheduler.lock);
    return num;
}

void fthread_init(void) {
    MUTEX_LOCK(&__scheduler.lock);
    if (__scheduler.worker_thread != NULL) {
        fthread_free(__scheduler.worker_thread);
        __scheduler.worker_thread = NULL;
    }
    for (size_t i = 0; i < __scheduler.num_threads; i++) {
        fthread_free(__scheduler.threads[i]);
        __scheduler.threads[i] = NULL;
    }
    free(__scheduler.threads);
    __scheduler.next_thread_number = 0;
    __scheduler.threads            = NULL;
    __scheduler.num_threads        = 0;
    __scheduler.capacity           = 0;
    MUTEX_UNLOCK(&__scheduler.lock);
    get_machine()->thread_once(&current_fthread_once, create_fthread_key);
}

void fthread_override(bool replace) {
    __use_fox_implementation = replace;
    if (!__has_overridden_functions) {
        fox_machine_t *machine = get_machine();
        must(mach_override_ptr(&pthread_create, &fthread_create, (void **)&machine->thread_create),
             "Failed to replace pthread_create");
        must(mach_override_ptr(&pthread_join, &fthread_join, (void **)&machine->thread_join),
             "Failed to replace pthread_join");
        must(mach_override_ptr(&pthread_detach, &fthread_detach, (void **)&machine->thread_detach),
             "Failed to replace pthread_detach");
        must(mach_override_ptr(&pthread_exit, &fthread_exit, (void **)&machine->thread_exit),
             "Failed to replace pthread_exit");
        must(mach_override_ptr(&pthread_mutex_lock, &fthread_mutex_lock, (void **)&machine->mutex_lock),
             "Failed to replace pthread_mutex_lock");
        must(mach_override_ptr(&pthread_cond_wait, &fthread_cond_wait, (void **)&machine->cond_wait),
             "Failed to replace pthread_cond_wait");
        must(mach_override_ptr(&pthread_cond_timedwait, &fthread_cond_timedwait, (void **)&machine->cond_timedwait),
             "Failed to replace pthread_cond_timedwait");
        must(mach_override_ptr(&sem_wait, &fox_sem_wait, (void **)&machine->sem_wait),
             "Failed to replace sem_wait");
        must(mach_override_ptr(&semaphore_wait, &fox_semaphore_wait, (void **)&machine->semaphore_wait),
             "Failed to replace semaphore_wait");
        must(mach_override_ptr(&semaphore_timedwait, &fox_semaphore_timedwait, (void **)&machine->semaphore_timedwait),
             "Failed to replace semaphore_timedwait");
        must(mach_override_ptr(&OSSpinLockLock, &fox_spinlock_lock, (void **)&machine->spinlock_lock),
             "Failed to replace semaphore_timedwait");
        __has_overridden_functions = true;
    }
}

#pragma mark - Scheduling Algorithms

static void fthread_schedule_round_robin(fthread_scheduler_t *scheduler) {
    bool has_runnable_threads = true;
    while (has_runnable_threads) {
        has_runnable_threads = false;
        MUTEX_LOCK(&scheduler->lock);
        size_t size = scheduler->num_threads;
        assert(size > 1);
        MUTEX_UNLOCK(&scheduler->lock);
        FTHREAD_DEBUG("Scheduler: %lu thread(s)\n", size);
        for (size_t i = 0; i < size; i++) {
            set_current_thread(scheduler->worker_thread);
            MUTEX_LOCK(&scheduler->lock);
            fthread_internal_t fthread = scheduler->threads[i];
            MUTEX_UNLOCK(&scheduler->lock);
            if (!fthread_is_complete(fthread)) {
                fthread_unyield(fthread);
                fthread_waitfor(fthread);
                has_runnable_threads = true;
            }
        }
    }
}
fthread_schedule_algorithm_t fthread_round_robin = fthread_schedule_round_robin;

static void fthread_schedule_random(fthread_scheduler_t *scheduler) {
    MUTEX_LOCK(&scheduler->lock);
    id<FOXRandom> random = (__bridge id<FOXRandom>)(scheduler->algorithm_data);
    if (!random) {
        fprintf(stderr, "No FOXRandom instance in algorithm data\n");
        abort();
    }
    size_t num_threads = scheduler->num_threads;
    FTHREAD_DEBUG("Scheduler: %lu thread(s)\n", num_threads);
    size_t mem_size = sizeof(fthread_internal_t) * num_threads;
    fthread_internal_t *incomplete_threads = FOXCalloc(mem_size, 1);
    memcpy(incomplete_threads, scheduler->threads, mem_size);
    MUTEX_UNLOCK(&scheduler->lock);

    size_t last_element = num_threads - 1;
    while (num_threads > 0) {
        size_t i = [random randomIntegerWithinMinimum:0
                                           andMaximum:last_element];
        fthread_internal_t fthread = incomplete_threads[i];
        set_current_thread(fthread);
        fthread_unyield(fthread);
        fthread_waitfor(fthread);

        if (fthread_is_complete(fthread)) {
            if (last_element != i) {
                memmove(incomplete_threads + i,
                        incomplete_threads + i + 1,
                        (num_threads - i - 1) * sizeof(fthread_internal_t));
            }
            --num_threads;
            --last_element;
        }
    }

    free(incomplete_threads);
}
fthread_schedule_algorithm_t fthread_random = fthread_schedule_random;

#pragma mark - Scheduler

/*! Main function for the scheduler's worker thread.
 */
static void *fthread_scheduler_main(fthread_scheduler_t *scheduler) {
    fthread_yield_thread(scheduler->worker_thread);
    scheduler->algorithm(scheduler);

    FTHREAD_DEBUG("Scheduler finished\n");
    semaphore_signal_without_aborting(scheduler->worker_thread->signal_to_yield);
    get_machine()->thread_exit(NULL);
    return NULL;
}

void fthread_run_and_wait(fthread_schedule_algorithm_t algo, void *algo_data) {
    FTHREAD_DEBUG("Main Start\n");

    fthread_scheduler_t *scheduler = &__scheduler;
    MUTEX_LOCK(&scheduler->lock);
    assert(scheduler->worker_thread == NULL);
    if (scheduler->worker_thread == NULL) {
        must(fthread_scheduler_create(&scheduler->worker_thread,
                                      THREAD_FN(&fthread_scheduler_main),
                                      scheduler),
             "Failed to create scheduler thread.");
    }
    scheduler->algorithm = algo;
    scheduler->algorithm_data = algo_data;
    fthread_internal_t scheduler_thread = scheduler->worker_thread;
    MUTEX_UNLOCK(&scheduler->lock);
    // "fake" fthread for debugging purposes (to see which threads is yields)
    struct __fthread t = (struct __fthread){
        .name = "Main",
    };

    set_current_thread(&t);
    fthread_unyield(scheduler_thread);
    fthread_waitfor(scheduler_thread);
    set_current_thread(NULL);
    FTHREAD_DEBUG("Main: Finished\n");
}

/*! Adds a given fthread to the scheduler's internal list of threads.
 *  Threadsafe.
 */
static void fthread_list_add(fthread_scheduler_t *scheduler, fthread_internal_t thread) {
    FTHREAD_DEBUG("Adding thread %s\n", thread->name);
    MUTEX_LOCK(&scheduler->lock);
    if (scheduler->capacity == scheduler->num_threads) {
        unsigned int new_cap = MAX(scheduler->capacity * 2, 10);
        scheduler->threads = FOXRealloc(scheduler->threads, sizeof(fthread_internal_t *) * new_cap);
        scheduler->capacity = new_cap;
    }
    scheduler->threads[scheduler->num_threads++] = thread;
    MUTEX_UNLOCK(&scheduler->lock);
}

/*! Gets the fthread for the given pthread_t type from the scheduler.
 *  Threadsafe.
 *
 *  Inefficient, but there usually isn't too many threads to keep track of, so
 *  it is OK.
 */
static fthread_internal_t fthread_list_get(fthread_scheduler_t *scheduler, pthread_t pthread) {
    fox_machine_t *machine = get_machine();
    fthread_internal_t fthread = NULL;
    MUTEX_LOCK(&scheduler->lock);
    for (unsigned int i = 0; i < scheduler->num_threads; i++) {
        if (machine->thread_equal(pthread, scheduler->threads[i]->pthread)) {
            fthread = scheduler->threads[i];
            break;
        }
    }
    MUTEX_UNLOCK(&scheduler->lock);
    return fthread;
}

#pragma mark - Threads

static void fthread_free(fthread_internal_t fthread) {
    if (fthread != NULL) {
        fox_machine_t *machine = get_machine();
        machine->semaphore_destroy(mach_task_self(), fthread->signal_to_unyield);
        machine->semaphore_destroy(mach_task_self(), fthread->signal_to_yield);
        free(fthread->name);
        free(fthread);
    }
}

/*! Cooperatively yields the current thread represented as fthread_t.
 *
 *  Blocks the current thread until it is unyielded by another thread.
 *
 *  Signals thread's signal_to_yield field.
 *  Waits on thread's signal_to_unyield field.
 */
static void fthread_yield_thread(fthread_internal_t fthread) {
    if (fthread) {
        FTHREAD_DEBUG("[%s] yields\n", fthread->name);
        MUTEX_LOCK(&fthread->state_lock);
        if (fthread->is_not_first_call) {
            MUTEX_UNLOCK(&fthread->state_lock);
            semaphore_signal_without_aborting(fthread->signal_to_yield);
        } else {
            fthread->is_not_first_call = true;
            MUTEX_UNLOCK(&fthread->state_lock);
        }
        semaphore_wait_without_aborting(fthread->signal_to_unyield);
        FTHREAD_DEBUG("[%s] resumes\n", fthread->name);
    }
}

/*! Unyields the given thread represented as fthread_t. Does not block the
 *  current thread.
 *
 *  Use fthread_waitfor() to block.
 */
void fthread_unyield(fthread_t ft) {
    fthread_internal_t fthread = (fthread_internal_t)ft;
    FTHREAD_DEBUG("[%s] unyields [%s]\n", get_current_thread()->name, fthread->name);
    semaphore_signal_without_aborting(fthread->signal_to_unyield);
}

/*! Waits for the given thread represented as fthread_t. Blocks the current
 *  thread until that thread calls fthread_yield().
 */
void fthread_waitfor(fthread_t ft) {
    fthread_internal_t fthread = (fthread_internal_t)ft;
    FTHREAD_DEBUG("[%s] waitsfor [%s]\n", get_current_thread()->name, fthread->name);
    semaphore_wait_without_aborting(fthread->signal_to_yield);
}

/*! Yields the current thread. Blocks the thread until it is unyield with
 *  fthread_unyield(..);
 */
void fthread_yield(void) {
    fthread_yield_thread(get_current_thread());
}

/* Returns the opaque type of the current thread.
 *
 * Unlike get_current_thread(), this will return NULL for the main thread.
 */
fthread_t fthread_current(void) {
    fthread_internal_t fthread = get_current_thread();
    if (fthread->user_main == NULL) {
        return NULL;
    }
    return fthread;
}

/*! Converts a pthread_t to its equivalent fthread_t if possible.
 *  Threadsafe.
 */
fthread_t fthread_get(pthread_t pthread) {
    return fthread_list_get(&__scheduler, pthread);
}

/*! Returns true if the current thread has finished executed.
 *  Threadsafe.
 */
static bool fthread_is_complete(fthread_internal_t fthread) {
    MUTEX_LOCK(&fthread->state_lock);
    bool is_complete = fthread->is_finished;
    MUTEX_UNLOCK(&fthread->state_lock);
    return is_complete;
}

/*! Main function for the threads fox manages.
 */
static void *fthread_main(fthread_internal_t fthread) {
    set_current_thread(fthread);
    void *result = fthread->user_main(fthread->user_data);
    MUTEX_LOCK(&fthread->state_lock);
    fthread->is_finished = true;
    MUTEX_UNLOCK(&fthread->state_lock);
    FTHREAD_DEBUG("[%s] exits normally\n", fthread->name);
    return result;
}

/*! Creates the scheduler thread.
 */
static int fthread_scheduler_create(fthread_internal_t *fthread_ptr, void *(*thread_main)(void *), void *thread_data) {
    fox_machine_t *machine = get_machine();

    int result = 0;
    fthread_internal_t fthread = FOXCalloc(sizeof(struct __fthread), 1);
    fthread->user_main         = thread_main;
    fthread->user_data         = thread_data;
    fthread->is_detached       = false;
    fthread->is_finished       = false;
    fthread->name              = FOXCStringOnHeap("fox.scheduler.%p", fthread);
    fthread->state_lock        = 0;

    _semaphore_create(&fthread->signal_to_unyield);
    _semaphore_create(&fthread->signal_to_yield);

    result = machine->thread_create(&fthread->pthread, NULL, thread_main, thread_data);
    if (result) {
        fthread_free(fthread);
    } else {
        *fthread_ptr = fthread;
    }
    return result;
}

/*! Creates a thread by the request of the api consumer.
 *  Overrides pthread_create(...)
 */
int fthread_create(pthread_t *pthread, pthread_attr_t *attr, void *(*thread_main)(void *), void *thread_data) {
    fox_machine_t *machine = get_machine();

    int result = 0;
    if (__use_fox_implementation) {
        fthread_internal_t fthread = FOXCalloc(sizeof(struct __fthread), 1);
        fthread->user_main         = thread_main;
        fthread->user_data         = thread_data;
        fthread->is_detached       = false;
        fthread->is_finished       = false;
        fthread->state_lock        = 0;
        fthread->name              = FOXCStringOnHeap("fox.thread.%u", next_thread_number());

        _semaphore_create(&fthread->signal_to_unyield);
        _semaphore_create(&fthread->signal_to_yield);

        result = machine->thread_create(pthread, attr, THREAD_FN(fthread_main), fthread);
        if (result) {
            fthread_free(fthread);
        } else {
            fthread->pthread = *pthread;
            fthread_list_add(&__scheduler, fthread);
        }
    } else {
        result = machine->thread_create(pthread, attr, thread_main, thread_data);
    }
    return result;
}

/*! Equivalent to pthread_detach(...)
 */
int fthread_detach(pthread_t pthread) {
    if (__use_fox_implementation) {
        fthread_internal_t fthread = fthread_list_get(&__scheduler, pthread);
        if (fthread) {
            MUTEX_LOCK(&fthread->state_lock);
            if (fthread->is_finished) {
                fthread_free(fthread);
            }
            fthread->is_detached = true;
            MUTEX_UNLOCK(&fthread->state_lock);
        }
    }
    return get_machine()->thread_detach(pthread);
}

/*! Equivalent to pthread_exit(...)
 */
void fthread_exit(void *data) {
    fthread_internal_t fthread = get_current_thread();
    MUTEX_LOCK(&fthread->state_lock);
    fthread->is_finished = true;
    MUTEX_UNLOCK(&fthread->state_lock);
    semaphore_signal_without_aborting(fthread->signal_to_yield);
    FTHREAD_DEBUG("[%s] exits via pthread_exit()\n", fthread->name);
    get_machine()->thread_exit(data);
}

/*! Equivalent to pthread_join(...)
 */
int fthread_join(pthread_t pthread, void **value_ptr) {
    int result = 0;
    if (__use_fox_implementation) {
        fthread_internal_t fthread = fthread_list_get(&__scheduler, pthread);
        result = get_machine()->thread_join(pthread, value_ptr);
        fthread_free(fthread);
    } else {
        result = get_machine()->thread_join(pthread, value_ptr);
    }
    return result;
}

#pragma mark - POSIX Mutex

/*! Equivalent to pthread_mutex_lock, but constantly yields instead of just
 *  blocking.
 */
int fthread_mutex_lock(pthread_mutex_t *mutex) {
    fox_machine_t *machine = get_machine();
    int result = 0;
    bool use_fox_impl = __use_fox_implementation;
#ifdef FOX_LOG_THREADS
    use_fox_impl = false;
#endif
    if (use_fox_impl) {
        while ((result = machine->mutex_trylock(mutex)) != 0) {
            if (result != EBUSY) {
                break;
            }
            fthread_yield();
        }
    } else {
        result = machine->mutex_lock(mutex);
    }
    return result;
}

#pragma mark - POSIX Cond

// return 1 if subtraction is negative
static int timespec_subtract(struct timespec *result, struct timespec x, struct timespec y) {
    if (x.tv_nsec < y.tv_nsec) {
        long nsec = (y.tv_nsec - x.tv_nsec) / 1000000 + 1;
        y.tv_nsec -= 1000000 * nsec;
        y.tv_sec += nsec;
    }
    if (x.tv_nsec - y.tv_nsec > 1000000) {
        long nsec = (x.tv_nsec - y.tv_nsec) / 1000000;
        y.tv_nsec += 1000000 * nsec;
        y.tv_sec -= nsec;
    }

    result->tv_sec = x.tv_sec - y.tv_sec;
    result->tv_nsec = x.tv_nsec - y.tv_nsec;

    return x.tv_sec < y.tv_sec;
}

/*! Equivalent to pthread_cond_timedwait, but constantly yields instead of just
 *  blocking.
 */
int fthread_cond_timedwait(pthread_cond_t *cond, pthread_mutex_t *mutex, const struct timespec *timespec) {
    fox_machine_t *machine = get_machine();
    int result = 0;
    if (__use_fox_implementation) {
        struct timespec remaining_timespec = *timespec;
        struct timespec deltatime = machine->yield_timespec;
        while ((result = machine->cond_timedwait(cond, mutex, &deltatime))) {
            if (result != ETIMEDOUT) {
                break;
            }

            struct timespec new_timespec;
            if (timespec_subtract(&new_timespec, remaining_timespec, deltatime)) {
                result = ETIMEDOUT;
                break;
            } else {
                remaining_timespec = new_timespec;
                fthread_yield();
            }
        }
    } else {
        result = machine->cond_timedwait(cond, mutex, timespec);
    }
    return result;
}

/*! Equivalent to pthread_cond_wait, but constantly yields instead of just
 *  blocking.
 */
int fthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex) {
    fox_machine_t *machine = get_machine();
    int result = 0;
    if (__use_fox_implementation) {
        struct timespec time = machine->yield_timespec;
        while ((result = machine->cond_timedwait(cond, mutex, &time))) {
            if (result != ETIMEDOUT) {
                break;
            }
            fthread_yield();
        }
    } else {
        result = machine->cond_wait(cond, mutex);
    }
    return result;
}

#pragma mark - POSIX Semaphores

/*! Equivalent to sem_wait, but constantly yields instead of just
 *  blocking.
 */
int fox_sem_wait(sem_t *sem) {
    fox_machine_t *machine = get_machine();
    int result = 0;
    if (__use_fox_implementation) {
        while ((result = machine->sem_trywait(sem))) {
            if (result != EAGAIN) {
                break;
            }
            fthread_yield();
        }
    } else {
        result = machine->sem_wait(sem);
    }
    return result;
}

#pragma mark - Mach Semaphores

// return 1 if subtraction is negative
static int mach_timespec_subtract(mach_timespec_t *result, mach_timespec_t x, mach_timespec_t y) {
    if (x.tv_nsec < y.tv_nsec) {
        long nsec = (y.tv_nsec - x.tv_nsec) / 1000000 + 1;
        y.tv_nsec -= 1000000 * nsec;
        y.tv_sec += nsec;
    }
    if (x.tv_nsec - y.tv_nsec > 1000000) {
        long nsec = (x.tv_nsec - y.tv_nsec) / 1000000;
        y.tv_nsec += 1000000 * nsec;
        y.tv_sec -= nsec;
    }

    result->tv_sec = x.tv_sec - y.tv_sec;
    result->tv_nsec = x.tv_nsec - y.tv_nsec;

    return x.tv_sec < y.tv_sec;
}

/*! Equivalent to semaphore_timedwait, but constantly yields instead of just
 *  blocking.
 */
kern_return_t fox_semaphore_timedwait(semaphore_t semaphore, mach_timespec_t wait_time) {
    fox_machine_t *machine = get_machine();
    kern_return_t result = 0;
    if (__use_fox_implementation) {
        mach_timespec_t remaining_timespec = wait_time;
        mach_timespec_t deltatime = {
            .tv_sec=(unsigned int)machine->yield_timespec.tv_sec,
            .tv_nsec=(clock_res_t)machine->yield_timespec.tv_nsec,
        };
        while ((result = machine->semaphore_timedwait(semaphore, deltatime))) {
            if (result != KERN_OPERATION_TIMED_OUT) {
                break;
            }

            mach_timespec_t new_timespec;
            if (mach_timespec_subtract(&new_timespec, remaining_timespec, deltatime)) {
                result = KERN_OPERATION_TIMED_OUT;
                break;
            } else {
                remaining_timespec = new_timespec;
                fthread_yield();
            }
        }
    } else {
        result = machine->semaphore_timedwait(semaphore, wait_time);
    }
    return result;
}

/*! Equivalent to semaphore_wait, but constantly yields instead of just
 *  blocking.
 */kern_return_t fox_semaphore_wait(semaphore_t semaphore) {
    fox_machine_t *machine = get_machine();
    kern_return_t result = 0;
    if (__use_fox_implementation) {
        mach_timespec_t deltatime = {
            .tv_sec=(unsigned int)machine->yield_timespec.tv_sec,
            .tv_nsec=(clock_res_t)machine->yield_timespec.tv_nsec,
        };
        while ((result = machine->semaphore_timedwait(semaphore, deltatime))) {
            if (result != KERN_OPERATION_TIMED_OUT) {
                break;
            }
            fthread_yield();
        }
    } else {
        result = machine->semaphore_wait(semaphore);
    }
    return result;
}

#pragma mark - OSSpinLocks

/*! Equivalent to OSSpinLockLock, but constantly yields instead of just
 *  blocking.
 */
void fox_spinlock_lock(volatile OSSpinLock *lock) {
    fox_machine_t *machine = get_machine();
    if (__use_fox_implementation) {
        while (!machine->spinlock_try(lock)) {
            fthread_yield();
        }
    } else {
        machine->spinlock_lock(lock);
    }
}

#import <pthread.h>
#import <semaphore.h>
#import <mach/mach.h>
#import <libkern/OSAtomic.h>

// code style: Matching POSIX style that what's it replaces

// maintainers: Don't forget to update get_machine() implementation too.
typedef volatile struct {
    // timespec fragment to yield. Default is {0 sec, 10 nsec}.
    struct timespec yield_timespec;

    // posix threads
    int (*thread_create)(pthread_t *thread,
                         const pthread_attr_t *attrs,
                         void *(*thread_main)(void *),
                         void *thread_data);
    int (*thread_join)(pthread_t thread, void **value_ptr);
    int (*thread_detach)(pthread_t thread);
    void (*thread_exit)(void *data);
    int (*thread_equal)(pthread_t, pthread_t);
    int (*thread_key_create)(pthread_key_t *key, void (*destructor)(void *));
    int (*thread_key_delete)(pthread_key_t key);

    int (*mutex_init)(pthread_mutex_t *mutex, const pthread_mutexattr_t *attrs);
    int (*mutex_trylock)(pthread_mutex_t *mutex);
    int (*mutex_lock)(pthread_mutex_t *mutex);
    int (*mutex_unlock)(pthread_mutex_t *mutex);
    int (*mutex_destroy)(pthread_mutex_t *mutex);

    int (*cond_init)(pthread_cond_t *cond, const pthread_condattr_t *attrs);
    int (*cond_timedwait)(pthread_cond_t *cond,
                          pthread_mutex_t *mutex,
                          const struct timespec *timespec);
    int (*cond_wait)(pthread_cond_t *cond, pthread_mutex_t *mutex);
    int (*cond_signal)(pthread_cond_t *cond);
    int (*cond_destroy)(pthread_cond_t *cond);

    // posix semaphores
    sem_t *(*sem_open)(const char *name, int oflag, ...);
    int (*sem_post)(sem_t *sem);
    int (*sem_trywait)(sem_t *sem);
    int (*sem_wait)(sem_t *sem);
    int (*sem_unlink)(const char *name);
    int (*sem_close)(sem_t *);

    // mach semaphores
    kern_return_t (*semaphore_create)(task_t task,
                                      semaphore_t *semaphore,
                                      int policy,
                                      int value);
    kern_return_t (*semaphore_signal)(semaphore_t semaphore);
    kern_return_t (*semaphore_signal_all)(semaphore_t semaphore);
    kern_return_t (*semaphore_wait)(semaphore_t semaphore);
    kern_return_t (*semaphore_timedwait)(semaphore_t semaphore,
                                         mach_timespec_t wait_time);
    // ideally, we should support these. But we don't
    //    kern_return_t (*semaphore_timedwait_signal)(semaphore_t wait_semaphore,
    //                                                semaphore_t signal_semaphore,
    //                                                mach_timespec_t wait_time);
    //    kern_return_t (*semaphore_wait_signal)(semaphore_t wait_semaphore,
    //                                           semaphore_t signal_semaphore);
    //
    //    kern_return_t (*semaphore_signal_thread)(semaphore_t semaphore,
    //                                             thread_t thread);
    kern_return_t (*semaphore_destroy)(task_t task, semaphore_t semaphore);

    // libkern
    bool (*spinlock_try)(volatile OSSpinLock *__lock);
    void (*spinlock_lock)(volatile OSSpinLock *__lock);
    void (*spinlock_unlock)(volatile OSSpinLock *__lock);
} fox_machine_t;

/*! Returns the machinery fox threads uses under the hood.
 *  None of the fields in this struct should point to fox functions.
 *
 *  @warning modifying this pointer is not thread safe.
 *           you should only modify this prior to using threads.
 */
fox_machine_t *get_machine(void);

#import "FOXThreadMachine.h"
#import "FOXMemory.h"

static fox_machine_t __machine = {
    .yield_timespec    = (struct timespec){.tv_sec=0, .tv_nsec=10},

    .thread_create     = &pthread_create,
    .thread_join       = &pthread_join,
    .thread_detach     = &pthread_detach,
    .thread_exit       = &pthread_exit,
    .thread_equal      = &pthread_equal,
    .thread_key_create = &pthread_key_create,
    .thread_key_delete = &pthread_key_delete,
    .mutex_init        = &pthread_mutex_init,
    .mutex_trylock     = &pthread_mutex_trylock,
    .mutex_lock        = &pthread_mutex_lock,
    .mutex_unlock      = &pthread_mutex_unlock,
    .mutex_destroy     = &pthread_mutex_destroy,
    .cond_init         = &pthread_cond_init,
    .cond_timedwait    = &pthread_cond_timedwait,
    .cond_wait         = &pthread_cond_wait,
    .cond_signal       = &pthread_cond_signal,
    .cond_destroy      = &pthread_cond_destroy,

    .sem_open    = &sem_open,
    .sem_post    = &sem_post,
    .sem_trywait = &sem_trywait,
    .sem_wait    = &sem_wait,
    .sem_unlink  = &sem_unlink,
    .sem_close   = &sem_close,

    .semaphore_create     = &semaphore_create,
    .semaphore_signal     = &semaphore_signal,
    .semaphore_signal_all = &semaphore_signal_all,
    .semaphore_wait       = &semaphore_wait,
    .semaphore_timedwait  = &semaphore_timedwait,
    .semaphore_destroy    = &semaphore_destroy,

    .spinlock_try  = &OSSpinLockTry,
    .spinlock_lock = &OSSpinLockLock,
    .spinlock_unlock = &OSSpinLockUnlock,
};

fox_machine_t *get_machine(void) {
    return &__machine;
}

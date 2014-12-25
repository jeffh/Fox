#import "FOXFiber.h"
#import <ucontext.h>
#import <string.h>
#import <stdlib.h>
#import <stdbool.h>
#import <setjmp.h>
#import <sys/time.h>
#import <unistd.h>
#import "FOXInstrumentation.h"
#import "FOXRandom.h"
#import "FOXMemory.h"

const unsigned int FIBER_STACK_SIZE = SIGSTKSZ;
const unsigned int RIP_INDEX = 10;

typedef struct _FOXFiber {
    char *name;
    void (*fiberMain)(void *);
    void *fiberData;

    pthread_t thread;
    pthread_mutex_t pauseMutex;
    
    sigjmp_buf context;
    sigjmp_buf *contextToYieldTo;
    void *stack;
    bool isRunning;
    bool isYielding;
} *FOXFiberPtr;

typedef struct _FOXFiberScheduler {
    sigjmp_buf context;
    FOXFiberRunner fiberRunner;
    FOXSchedulingAlgorithm scheduler;
    void *schedulerData;
    FOXFiberPtr *fibers;
    size_t count;
    size_t capacity;
} FOXFiberScheduler, *FOXFiberSchedulerPtr;

static FOXFiberPtr currentFiber;
static FOXFiberSchedulerPtr runningScheduler;

void _FOXFiberSchedulerYieldCooperatively(FOXFiberSchedulerPtr s, FOXFiberPtr f);

FOXFiberPtr FOXFiberCreate(char *name,
                           void (*fiberMain)(void *),
                           void *fiberData) {
    FOXFiberPtr f = (FOXFiberPtr)FOXCalloc(sizeof(struct _FOXFiber), 1);
    size_t len = strlen(name);
    f->name = FOXCalloc(sizeof(char), len);
    strncpy(f->name, name, len);
    f->fiberMain = fiberMain;
    f->fiberData = fiberData;
    f->stack = FOXMalloc(FIBER_STACK_SIZE);
    return f;
}

void FOXFiberFree(FOXFiberPtr f) {
    if (f != NULL) {
        free(f->stack);
        free(f->name);
        free(f);
    }
}

void *FOXFiberGetData(FOXFiberPtr f) {
    return f->fiberData;
}

void FOXFiberYield(FOXFiberPtr f) {
    f = f ?: currentFiber;
    if (f && !f->isYielding) {
        f->isYielding = true;
        if (sigsetjmp(f->context, 1) == 0) {
            siglongjmp(*f->contextToYieldTo, 1);
        }
        f->isYielding = false;
    }
}

void FOXFiberYieldIfInstrumented(void) {
    if (FOXIsInstrumented()) {
        FOXFiberYield(NULL);
    }
}

void _FOXFiberRun(void *fiber) {
    FOXFiberPtr f = fiber;
    f->fiberMain(f->fiberData);
    f->isRunning = 0;
    FOXFiberYield(f);
}

#pragma mark - Fiber Scheduler

FOXFiberSchedulerPtr FOXFiberSchedulerCreate(FOXSchedulingAlgorithm algorithm,
                                             void *algorithmData) {
    FOXFiberSchedulerPtr s = FOXCalloc(sizeof(FOXFiberScheduler), 1);
    s->fiberRunner = &_FOXFiberSchedulerYieldCooperatively;
    s->scheduler = algorithm;
    s->schedulerData = algorithmData;
    return s;
}

void FOXFiberSchedulerFree(FOXFiberSchedulerPtr s) {
    if (s != NULL) {
        for (size_t i = 0; i < s->count; i++) {
            FOXFiberFree(s->fibers[i]);
            s->fibers[i] = NULL;
        }
        free(s->fibers);
        free(s);
    }
}

void FOXFiberSchedulerAdd(FOXFiberSchedulerPtr s, FOXFiberPtr f) {
    if (s->capacity == s->count) {
        size_t newCapacity = s->capacity * 2 + 1;
        s->fibers = FOXRealloc(s->fibers, sizeof(FOXFiberPtr) * newCapacity);
        s->capacity = newCapacity;
    }
    s->fibers[s->count] = f;
    f->contextToYieldTo = &s->context;

    s->count++;
}

size_t FOXFiberSchedulerCount(FOXFiberSchedulerPtr s) {
    return s->count;
}

FOXFiberPtr FOXFiberSchedulerGet(FOXFiberSchedulerPtr s, size_t index) {
    return s->fibers[index];
}

static sig_atomic_t _FOXFiberSchedulerCreateStack__count;
FOX_EXPORT void _FOXFiberSchedulerCreateStack(int sig) {
    if (++_FOXFiberSchedulerCreateStack__count == 1) {
        if (sigsetjmp(currentFiber->context, 1)) {
            _FOXFiberRun(currentFiber);
        }
    }
    --_FOXFiberSchedulerCreateStack__count;
}

void _FOXFiberSchedulerSpawn(FOXFiberSchedulerPtr s, FOXFiberPtr f) {
    struct sigaction handler;
    struct sigaction oldHandler;
    stack_t fiberStack;
    stack_t mainStack;

    currentFiber = f;

    f->contextToYieldTo = &s->context;

    fiberStack.ss_flags = 0;
    fiberStack.ss_size = FIBER_STACK_SIZE;
    fiberStack.ss_sp = f->stack;

    handler.sa_handler = &_FOXFiberSchedulerCreateStack;
    handler.sa_flags = SA_ONSTACK | SA_NODEFER;
    sigemptyset(&handler.sa_mask);

    if (sigaltstack(&fiberStack, &mainStack)) {
        fprintf(stderr, "sigaltstack(&fiberStack, &mainStack) failed\n");
        exit(2);
    }

    if (sigaction(SIGALRM, &handler, &oldHandler)) {
        fprintf(stderr, "sigaction(SIGUSR1, %p, %p) failed\n", &handler, &oldHandler);
        exit(2);
    }

    if (raise(SIGALRM)) {
        fprintf(stderr, "raise(SIGUSR1) failed\n");
        exit(2);
    }

    // restore state for the main "fiber"
    sigaction(SIGALRM, &oldHandler, NULL);
    sigaltstack(&mainStack, NULL);

    currentFiber = NULL;
    f->isRunning = true;
}

void FOXFiberSchedulerRun(FOXFiberSchedulerPtr s) {
    runningScheduler = s;

    for (size_t i = 0; i < s->count; i++) {
        FOXFiberPtr f = s->fibers[i];
        _FOXFiberSchedulerSpawn(s, f);
    }

    s->scheduler(s);
    runningScheduler = NULL;
}

#pragma mark Fiber Running Techniques

void _FOXFiberSchedulerYieldCooperatively(FOXFiberSchedulerPtr s, FOXFiberPtr f) {
    currentFiber = f;
    if (sigsetjmp(s->context, 1) == 0) {
        siglongjmp(f->context, 1);
    }
    f->isYielding = false;
    currentFiber = NULL;
}

#pragma mark Scheduling Algorithms

void _FOXFiberSchedulerRoundRobin(FOXFiberSchedulerPtr s) {
    int hasRanFiber = true;
    while (hasRanFiber) {
        hasRanFiber = false;
        for (size_t i = 0; i < s->count; i++) {
            FOXFiberPtr f = s->fibers[i];
            if (f->isRunning) {
                s->fiberRunner(s, f);
                hasRanFiber = true;
            }
        }
    }
}

FOXSchedulingAlgorithm FOXFiberSchedulerRoundRobin = &_FOXFiberSchedulerRoundRobin;

void _FOXFiberSchedulerRandom(FOXFiberSchedulerPtr s) {
    id<FOXRandom> random = s->schedulerData;

    const size_t elementSize = sizeof(FOXFiberPtr);
    size_t count = s->count;
    FOXFiberPtr *runningFibers = FOXMalloc(elementSize * s->count);
    memcpy(runningFibers, s->fibers, s->count * elementSize);
    while (count > 0) {
        size_t index = [random randomIntegerWithinMinimum:0 andMaximum:count - 1];
        FOXFiberPtr fiber = runningFibers[index];
        s->fiberRunner(s, fiber);
        if (!fiber->isRunning) {
            // remove fiber from the array
            if (index != count - 1) {
                size_t numElementsToMove = count - index - 1;
                memmove(runningFibers + index,
                        runningFibers + index + 1,
                        numElementsToMove * elementSize);
            }
            count--;
        }
    }
    free(runningFibers);
}
FOXSchedulingAlgorithm FOXFiberSchedulerRandom = &_FOXFiberSchedulerRandom;

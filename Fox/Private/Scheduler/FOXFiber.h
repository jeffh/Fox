// Fiber Implementation. Alternatively may be known as all-to-one cooperative
// thread scheduling.
#import "FOXMacros.h"

typedef struct _FOXFiber *FOXFiberPtr;
typedef struct _FOXFiberScheduler *FOXFiberSchedulerPtr;
typedef void (*FOXSchedulingAlgorithm)(FOXFiberSchedulerPtr);
typedef void (*FOXFiberRunner)(FOXFiberSchedulerPtr, FOXFiberPtr);

#pragma mark - Fiber

/*! Creates a new fiber that executes the given main function pointer with
 *  the associated fiberData to pass to.
 *
 *  @param name A name to help identify the fiber. The fiber does not use this
 *              parameter internally, but will copy the string.
 *  @param fiberMain The function pointer to call for this fiber
 *  @param fiberData The data to pass to the given function pointer. The fiber
 *                   will not clean up this memory. Use fuberMain to do so.
 *  @returns a new yielded fiber.
 */
FOXFiberPtr FOXFiberCreate(char *name,
                           void (*fiberMain)(void *),
                           void *fiberData);

/*! Gets the data point currently associated with the fiber.
 */
FOX_EXPORT void *FOXFiberGetData(FOXFiberPtr fiber);

/*! Deallocates data created by FOXFiberCreate.
 */
FOX_EXPORT void FOXFiberFree(FOXFiberPtr fiber);

/*! Yields the given fiber. Pass NULL to use the curently executing fiber.
 */
FOX_EXPORT void FOXFiberYield(FOXFiberPtr fiber);
/*! Yields the current executing fiber if FOXIsInstrumented is true.
 */
FOX_EXPORT void FOXFiberYieldIfInstrumented(void);

#pragma mark - Scheduler

FOX_EXPORT FOXFiberSchedulerPtr FOXFiberSchedulerCreate(FOXSchedulingAlgorithm algorithm,
                                                        void *algorithmData);
FOX_EXPORT void FOXFiberSchedulerFree(FOXFiberSchedulerPtr scheduler);
FOX_EXPORT void FOXFiberSchedulerAdd(FOXFiberSchedulerPtr scheduler, FOXFiberPtr fiber);
FOX_EXPORT FOXFiberPtr FOXFiberSchedulerGet(FOXFiberSchedulerPtr scheduler, size_t index);
FOX_EXPORT size_t FOXFiberSchedulerCount(FOXFiberSchedulerPtr scheduler);
FOX_EXPORT void FOXFiberSchedulerRun(FOXFiberSchedulerPtr scheduler);

#pragma mark Scheduling Algorithms

/*! Round Robin Scheduling - each fiber gets an even distribution of yields.
 *
 *  Does not use algorithmData, so it can be set to NULL.
 */
FOX_EXPORT FOXSchedulingAlgorithm FOXFiberSchedulerRoundRobin;

/*! Random Scheduling - each fiber gets a random, uneven distribution of yields.
 *
 *  algorithmData must be set to a id<FOXRandom> instance.
 */
FOX_EXPORT FOXSchedulingAlgorithm FOXFiberSchedulerRandom;

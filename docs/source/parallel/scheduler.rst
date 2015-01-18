.. highlight:: objective-c

Fox's Thread Scheduler
======================

.. warning:: This documentation and API is ALPHA and is subject to change.
             Alpha APIs are **not** under :ref:`semantic versioning
             <semantic-versioning>` and can change freely between versions.

This covers more technical details of Fox's thread scheduler. While not
essential to know, reading this can provide insight to potential quirks of the
implementation.

Overview
--------

Fox's scheduling system has two goals: be easily injectable to existing code,
and to control thread execution order. It implements a pthread-like interface
by relying mostly on the system pthreads implementation. There are specific
functions that have custom implementations:

- thread creation and destruction to track threads.
- locks and mutexes to be cooperatively scheduled.
- fox-specific APIs to control thread execution (yielding, scheduling, etc.)

Then, `mach_override`_ is used to replace pthread methods. Currently, the
following functions can be assumed to be overridden (although, it may not always):

- pthread functions (threads, mutexes, cond variables)
- POSIX semaphores (that are not deprecated by OS X or iOS)
- Mach semaphores
- OSSpinLock

These overrides are global for the entire process. That means libraries will
also trigger Fox's custom code when hooks take place. If you find apis that
should be supported `file an issue`_.

Currently, **Fox's function replacement is permanent**. A flag is set
internally to trigger the original code or Fox's custom code. While this detail
is minor, it has a possibility of creating differences in execution time and
preemptive scheduling when not using Fox's scheduler.

.. note:: Using Fox does not override usage of explicit kernel threads.

.. _file an issue: http://github.com/jeffh/Fox/issues
.. _mach_override: https://github.com/rentzsch/mach_override

.. _FOXScheduler:

Using the Scheduler
-------------------

The public API of Fox's scheduler is purposefully kept small. ``FOXScheduler``
is the public interface to Fox's C scheduler. Let's look at the methods::

    @interface FOXScheduler : NSObject

    - (instancetype)initWithRandom:(id<FOXRandom>)random;
    - (instancetype)initWithRandom:(id<FOXRandom>)random
            replaceSystemFunctions:(BOOL)replaceThreads;
    - (void)runAndWait:(void(^)())block;

    @end

``-[initWithRandom:]`` is recommended to use the majority of the time. It
simply calls through to ``-[initWithRandom:random replaceSystemFunctions:YES]``.
Random is used for indirectly dictating the ordering of threads for the
scheduler to run.

When ``replaceSystemFunctions`` is ``YES``, then Fox will use mach_override to
replace the system functions. Using ``NO`` will require manually cooperation for
threads **and locks**.

Use ``-[runAndWait:]`` to activate Fox's scheduler for the given block. The
method will block until all the threads finishes executing. Note that
``runAndWait:`` only captures threads inside the block. This can be problematic
for GCD queues, which can create threads.

In order for cooperative scheduling to work properly,
:c:func:`FOXSchedulerYield` needs to be calls throughout all the threads to
"mark" break points.

Due to implementation reasons of ``NSThread``, the scheduler cannot force a
thread to yield immediately. Instead, manually insert an explicit yield to
pause a thread at startup::

    NSThread *thread = [[NSThread alloc] initWithTarget:myObject
                                               selector:@selector(run)
                                                 object:nil];
    [thread start];

    // implementation of run
    - (void)run {
      FOXSchedulerYield();
      // do work.
    }

Not doing this will cause threads to run in parallel immediately.
:c:func:`FOXRunParallelProgram` does this automatically.

Cooperative Scheduling
----------------------

Fox's threading implementation is a `user-level`, `cooperatively scheduled`_
library. **User-level** means it's not implemented in terms of the OS.
**Cooperatively scheduled** means threads must explicitly yield execution to
another thread (unlike normal threads which get preemptively yielded by the
scheduler).

Preemptive scheduling is complex for programs - usually require `complex signal
handling`_ for some basic reliability and does not allow Fox to retain full
execution control.

.. _user-level: http://cs.stackexchange.com/questions/1065/what-is-the-difference-between-user-level-threads-and-kernel-level-threads
.. _cooperatively scheduled: http://en.wikipedia.org/wiki/Thread_(computing)#Scheduling
.. _complex signal handling: https://mikeash.com/pyblog/friday-qa-2011-04-01-signal-handling.html

Fox's threads aren't particularly useful for anything other than testing.
In fact, they're actually *slower* that normal thread or serial execution.

Fox's threading library "serializes" all thread execution (like event-IO or
fiber libraries). Fox can control the order of execution of threads with a
custom thread scheduler. This gives more control to help make parallel tests
more deterministic.

Of course, Fox's scheduler works hand-in-hand with :doc:`the Foxling Compiler
<compiler>` to avoid having to manually insert thread yields (which is very
error-prone).


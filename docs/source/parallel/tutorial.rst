.. highlight:: objective-c

Parallel Testing Tutorial
=========================

.. warning:: This documentation and API is ALPHA and is subject to change.
             Alpha APIs are **not** under :ref:`semantic versioning
             <semantic-versioning>` and can change freely between versions.

.. note:: **This tutorial does not cover asynchronous testing.** Async testing
          is a different feature and requires specifying a temporal model that
          Fox currently does not implement.

If you haven't already, :doc:`install the Foxling Compiler Plugin
<installation>` before continuing.

The Multithreading Problem Space
---------------------------------

Parallel testing is more difficult than standard testing.

There are many factors that threading code can experience:

- **Atomic**: Multiple threads access the same resource but may access stale data and critical sections.
- **Reordering**: Compiled or executed code can be reordered by the OS or CPU in comparison to the original source.
- **Race Conditions**: behavior of the code changes depending on how the OS or language runtime executes each thread.
- **Partial read/writes**: data can be partially read or written before being preempted to run another thread.
- **Deadlocks**: Multiple threads block for resources (locks) that each other thread is holding.
- **Starvation**: Certain threads get less or no execution time in comparison to other threads due to locking or scheduling.

Fox cannot cover all these scenarios, but can help find bugs some cases.

Fox's Solution
--------------

Fox relies on :ref:`state machine <Testing Stateful APIs>` infrastructure to
test parallel APIs. The state machine is assumed to be atomic against multiple
threads using the subject's API.

To help control the non-deterministic nature of parallel code, Fox can
optionally replace `pthreads`_ and some darwin APIs with a cooperative threads
implementation. Along with :doc:`Foxling <compiler>`, Fox can greatly increase
the likelihood of finding hard-to-find race conditions that may be hard to
detect with traditional unit testing.

Foxling is :doc:`installed as an Xcode plugin <installation>`. If you
have already gotten it installed, continue with the :doc:`parallel testing
tutorial <tutorial>`.

.. _memory barrier: http://en.wikipedia.org/wiki/Memory_barrier
.. _pthreads: http://en.wikipedia.org/wiki/POSIX_Threads

Fox supports testing via :ref:`state machines <Testing Stateful APIs>`. Simply
replace all the ``Serial`` API calls with ``Parallel``::

    // generate an arbitrary sequence of API calls that execute in parallel
    id<FOXGenerator> programs = FOXParallelProgram(stateMachine);
    // verify that all the executed commands properly conformed to the state machine.
    FOXAssert(FOXForAll(programs, ^BOOL(FOXProgram *program) {
        FOXExecutedProgram *executedProgram = FOXRunParallelProgram(program, ^id{
            Queue *subject = [Queue new];
            return subject;
        });
        return FOXReturnOrRaisePrettyProgram(executedProgram);
    }));

Limited Parallel Execution
--------------------------

Program generation are limited form of parallel testing. Fox creates parallel
programs by creating a serial command prefix and then running:

- **1** to **3** threads
- **1** to **2** commands per thread

While seemingly small, `a study seems to indicate`_ that parallel tests can be
relatively small to exhibit common failures:

- A partial ordering of 2 threads caused a failure (96% of 105 real-world programs)
- A particular ordering of four memory accesses (92% of 105 real-world programs)

Fox, and QuickCheck, takes this assumption with its testing strategy. So keep
in mind that **Fox cannot ensure thread-safety**, but can detect many common
errors.

.. _a study seems to indicate: http://www.cs.columbia.edu/~junfeng/09fa-e6998/papers/concurrency-bugs.pdf

Deterministic Non-Determinism
-----------------------------

Running the above code will reveal one inherit problem with parallel tests,
they're non-deterministic! This makes it difficult for Fox to reliably shrink a
failing test case because it cannot reliably tell if a smaller example will
also fail when running in parallel.

A naive solution is to simply rerun test cases. :c:func:`FOXAlways` can help
that, but that's an ugly hack to try and get around that problem.

What we really need is to *control* the order in when threads are executed. Fox
can do this with :ref:`FOXScheduler <FOXScheduler>`. This is an interface to a
`user-level`_, `cooperatively scheduled`_ threading library.

.. _user-level: http://cs.stackexchange.com/questions/1065/what-is-the-difference-between-user-level-threads-and-kernel-level-threads
.. _cooperatively scheduled: http://en.wikipedia.org/wiki/Thread_(computing)#Scheduling

Along with overriding existing `pthreads`_ with Fox's own threading library at
runtime, Fox can hijack other systems that use pthreads internally - such as
``NSThread``.

.. _pthreads: http://en.wikipedia.org/wiki/POSIX_Threads

**There's one caveat.** Since it's cooperatively threading. Threads **must
explicitly yield execution control to the scheduler** in order to switch
between threads.  While it seems to be a deal-breaker, we'll come back around
and address this issue.

The scheduler can be accessed via :ref:`FOXScheduler <FOXScheduler>`::

    id<FOXRandom> random = [[FOXDeterministicRandom alloc] init];
    FOXScheduler *scheduler = [[FOXScheduler alloc] initWithRandom:random];
    [scheduler runAndWait:^{
        // create and use threads
    }];

Notice that the scheduler requires a random number generator. The number
generator indirectly dictates thread execution order. The block for
``runAndWait:`` should create and run threads. The scheduler will automatically
wait until no threads can be executed before returning.

:c:func:`FOXRunParallelProgram` internally uses NSThreads, which uses pthreads in
turn. So we'll put that in the block and use :c:func:`FOXSeed` to generate a
random number generator::

    // generate an arbitrary sequence of API calls that execute in parallel
    // along with a random number generator
    id<FOXGenerator> tuples = FOXTuple(@[FOXParallelProgram(stateMachine),
                                         FOXSeed()]);
    FOXAssert(FOXForAll(tuples, ^BOOL(NSArray *tuple) {
        FOXProgram *program = tuple[0];
        id<FOXRandom> random = tuple[1];

        FOXScheduler *scheduler = [[FOXScheduler alloc] initWithRandom:random];
        __block FOXExecutedProgram *executedProgram = nil;
        [scheduler runAndWait:^{
            executedProgram = FOXRunParallelProgram(program, ^id{
                Queue *subject = [Queue new];
                return subject;
            });
        }];
        return FOXReturnOrRaisePrettyProgram(executedProgram);
    }));

:c:func:`FOXRunParallelProgram` does some cooperatively yielding by calling
``FOXSchedulerYield``. Not yielding makes the scheduler view blocks of code
as atomic. That's not what we want our Queue's code that we're testing.
However, manually adding yield statements is time-consuming and error-prone.
The better solution is to have a program do this for us...

Foxling, The Compiler
---------------------

Fox comes with its own compiler, call :doc:`Foxling <compiler>`. It's based off
of Clang and its only job is to automatically insert ``FOXSchedulerYield();``
statements at compile time.

If you haven't done so, now would be great to :doc:`install the Foxling Xcode
Plugin <installation>`.

It's recommended to create a new targets for your application and parallel
tests to utilize the Foxling compiler. It should be idential to your original
targets except for setting:

.. image:: images/xcode-compiler-setting.png

Which is available after the plugin is installed. One more thing is to make
sure Fox is linked to both your application and tests to ensure the compiler
can correctly lookup ``FOXSchedulerYield``.

Now compiling will automatically insert yields into our source!

Final Caveats
-------------

It's worth noting that **Foxling can only insert yields for code it compiles**.
This means that libraries that aren't compiled with Foxling behave atomically
unless otherwise noted by Fox's threading library.

Since Foxling calls through to Apple's Clang (which has different behavior to
the open-sourced Clang), compiling with Foxling can be significantly slower.

Finding parallel bugs in your program can be greatly affected by when yields
are inserted into your program. Foxling currently only inserts yields:

- before each statement in a C-block (every statement ends with a ``;``
  inside ``{ }``).
- between read and write operations of (``++``/``--``) unary operators.
- between objective-c message send calls and computing the receiver.
- before setting a property value, but after computing the property's intended
  value.

Also, Foxling currently cannot parse Swift code and is untested on C++ code.



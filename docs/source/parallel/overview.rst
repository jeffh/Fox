.. highlight:: objective-c

Parallel Testing Overview
=========================

.. warning:: Currently this API is ALPHA and is subject to change. Alpha APIs
             are **not** under :ref:`semantic versioning <semantic-versioning>`.

Parallel testing is more difficult than standard testing. Fox does support
testing parallel code with caveats. First, let's talk about the problems with
parallel testing.

Code executing in multiple threads suffer from keeping track of state on
multiple levels of abstraction. Consider this pseudocode::

    // pseudocode
    var a = 0;
    var b = 0;
    create_thread { // thread 1
        a = 10;
        b = 20;
    }
    create_thread { // thread 2
        printf("%d, %d", a, b)
    }

What are some possible permutations that get printed?

1. prints "0, 0"
2. prints "10, 0"
3. prints "10, 20"
4. prints "0, 20"

Permutation #4 is interesting. The CPU and compiler are free to reorder
statements as long as the behavior remains the same for a thread. This means
the compiler can reorder the first thread's code to::

    create_thread { // thread 1
        b = 20;
        a = 10;
    }

Or the CPU can choose to do this. To prevent this, a `memory barrier`_ is
required to tell the CPU and compiler that ordering and aggressive caching
rules must be relaxed.

There are many factors that production threading code experiences:

- Atomic: Multiple threads access the same resource but may access stale data and critical sections.
- Reordering: Compiled or executed code can be reordered by the OS or CPU in comparison to the original source.
- Race Conditions: behavior of the code changes depending on how the OS or language runtime executes each thread.
- Partial read/writes: data can be partially read or written before being preempted to run another thread.
- Deadlocks: Multiple threads block for resources (locks) that each other thread is holding.
- Starvation: Certain threads get less or no execution time in comparison to other threads due to locking or scheduling.

Fox cannot cover all these scenarios, but can help discover some of these cases.

Currently Fox relies on :ref:`state machine <Testing Stateful APIs>`
infrastructure to test parallel APIs.

To help control the inheritly non-deterministic nature of parallel code, Fox
employs two techniques: function overriding and a custom compiler.

Fox can optionally replace `pthreads`_ and some darwin APIs with a cooperative
threads implementation. Along with :doc:`Foxling </parallel/foxling>`, Fox's
cooperative threading compiler, Fox can greatly increase the likelihood of
finding hard-to-find race conditions that may be rare for traditional unit
testing.

Because of Foxling, parallel testing requires futher :def:`installation
</parallel/installation>`. If you have already gotten set up for parallel
testing, continue with the :doc:`parallel testing tutorial </parallel/tutorial>`.

.. _memory barrier: http://en.wikipedia.org/wiki/Memory_barrier
.. _pthreads: http://en.wikipedia.org/wiki/POSIX_Threads

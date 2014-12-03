.. highlight:: objective-c

Runner Overview
===============

The runner is how Fox executes properties, seeds data generation, and performs
shrinking. Although you can create and use the runner directly via
``FOXRunner``, it is more common to use wrappers -- such as ``FOXAssert``.

``FOXAssert`` takes a property assertion (only ``FOXForAll`` for now) to assert
against. An exception is raised when the property fails to hold.

A more flexible ``FOXAssertWithOptions`` can be used to provide parameters that
is normally accepted by the runner.

.. _Configuring Test Generation:

Configuring Test Generation
---------------------------

By default, Fox will generate **500 tests per assertion** with a **maximum size
of 200** and a random seed. By changing ``FOXAssert`` to ``FOXAssertWithOptions``
we can provide optional configuration by using the ``FOXOptions``::

    FOXAssertWithOptions(FOXForAll(...), (FOXOptions){
        seed=5,              // default: time(NULL)
        numberOfTests=1000,  // default: 500
        maximumSize=100,     // default: 200
    });

This allows you to configure the test generation. In three ways:

- ``seed`` allows you to set the random number generator. This allows you to
  set the PRNG to help reproduce failures that Fox may have generated during a
  test run.  Setting this to the default (``0``) will make Fox generate a seed
  based on the current time.
- ``numberOfTests`` indicates the number of tests Fox will generate for this
  particular property. More tests generated will more thoroughly cover the
  property at the cost of time. Setting this to the default (``0``) will make Fox
  run ``500`` tests.
- ``maximumSize`` indicates the maximum size factor Fox will use when
  generating tests. Generators use this size factor as a hint to produce data
  of the appropriate sizes. For example, ``FOXInteger`` will generate integers
  within the range of 0 to ``maximumSize`` and ``FOXArray`` will generate
  arrays whose number of elements are in the range of 0 to ``maximumSize``.
  Setting this to the default (``0``) will make Fox run with a ``maximumSize``
  of ``200``.  If you know this property's data generation can tolerate larger
  sizes, feel free to increase this. Large collection generation can be
  prohibitively expensive.

Please note that ``seed``, ``numberOfTests``, and ``maximumSize`` should all be
recorded to reproduce a failure that Fox may have generated.


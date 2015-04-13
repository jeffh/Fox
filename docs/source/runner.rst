.. highlight:: objective-c

Runner Overview
===============

The runner is how Fox executes properties, seeds data generation, and triggers
shrinking. Although you can create and use the runner directly via
``FOXRunner``, it is more common to use wrappers -- such as ``FOXAssert``.

``FOXAssert`` takes a property assertion generator (only ``FOXForAll`` for
now). An exception is raised when the property fails to hold.

A more flexible ``FOXAssertWithOptions`` can be used to provide parameters that
is normally accepted by the runner.

.. _Configuring Test Generation:

Configuring Test Generation
---------------------------

The primary operation of Fox's runner is to create and execute tests. There are
three parameters to configure Fox's test generation:

- The **seed** allows you to seed the random number generator Fox uses. This
  allows you to set the PRNG to help reproduce failures that Fox may have
  generated during a test run.  Setting this to the default (``0``) makes
  Fox generate a seed based on the current time.
- The **number of tests** indicates the number of tests Fox generates for
  this particular property. More tests generated will more thoroughly cover the
  property at the cost of time. Setting this to the default (``0``) makes
  Fox run ``500`` tests.
- The **maximum size** indicates the maximum size factor Fox uses when
  generating tests. Generators use this size factor as a hint to produce data
  of the appropriate sizes. For example, ``FOXInteger`` generates integers
  within the range of 0 to ``maximumSize`` and ``FOXArray`` generates
  arrays whose number of elements are in the range of 0 to ``maximumSize``.
  Setting this to the default (``0``) makes Fox run with a ``maximumSize``
  of ``200``.  If you know this property's data generation can tolerate larger
  sizes, feel free to increase this. Large collection generation can be
  prohibitively expensive.

Please note that **seed**, **number of tests**, and **maximum size** should all
be recorded to reproduce a failure that Fox may have generated.

Per Assertion Configuration
---------------------------

By default, Fox generates **500 tests per assertion** with a **maximum size of
200** and a random seed. By changing ``FOXAssert`` to ``FOXAssertWithOptions``
we can provide optional configuration by using the ``FOXOptions``::

    FOXAssertWithOptions(FOXForAll(...), (FOXOptions){
        .seed=5,              // default: time(NULL)
        .numberOfTests=1000,  // default: 500
        .maximumSize=100,     // default: 200
    });

Global Configuration
--------------------

Values can be overridden using `environment variables`_ to globally change the
defaults.

.. note:: Note that as of this time of writing, ``xcodebuild test`` (command
          line) does not properly pass environment variables to test bundles
          for iOS. Use the setter style listed after the environment variables
          instead.

          It is fine to set environment variables via Xcode.

- Setting ``FOX_SEED`` can specify a specific seed to run for all properties.
- Setting ``FOX_NUM_TESTS`` sets the number of tests to generate for each
  property.
- Setting ``FOX_MAX_SIZE`` sets the maximum size factor Fox uses to when
  generating tests.

.. _environment variables: http://nshipster.com/launch-arguments-and-environment-variables/

If you cannot use environment variables, Fox also allows you to manually
override the values via setters:

- ``FOXSetSeed(NSUInteger seed)`` sets the random seed.
- ``FOXSetNumberOfTests(NSUInteger numTests)`` sets the number of tests.
- ``FOXSetMaximumSize(NSUInteger maxSize)`` sets the maximum size.

An easy way to use these setters would be in an ``+[initialize]``  or ``+[load]`` method::

    @interface TestHelper : NSObject
    @end

    @implementation TestHelper

    + (void)initialize {
      if (self == [TestHelper class]) {
        FOXSetNumberOfTests(200);
        FOXSetMaximumSize(50);
      }
    }

    @end

Using compile-time settings or macros, you can conditionally customize the
values as needed.

Configuration Priority
----------------------

Even though Fox accepts many different ways of setting global configuration,
there is a specific ordering Fox checks for configuration values.

The priority that Fox takes for these configurations are in order:

1. The per-assertion configuration if provided.
2. The environment variable overrides if provided.
3. The setter function values are used if provided.
4. Fox's internal default values are used.

.. _Random Number Generators:

Random Number Generators
------------------------

Fox provides a hook for custom pseudo-random number generation.
This is also what generators receive as their first argument.

The runner uses ``FOXDeterministicRandom`` which uses `C++ random`_ by default.
This keeps randomization state isolated from any other potential system that
uses a global PRNG. But you can implement the ``FOXRandom`` protocol to support
custom random schemes.

Another implementation Fox provides out of the box is ``FOXConstantRandom``,
which always generates a constant number. This can be useful for testing
generators with example-based tests.

.. _C++ random: http://www.cplusplus.com/reference/random/

.. _Reporters:

Reporters
---------

The runner also provides a way to observe its operation via a reporter.
Reporters are a `delegate`_ to the runner. They are invoked synchronously, so
be careful about its performance impact on execution.

Delegates cannot influence the execution of the runner, but can provide useful
user-facing output about the progress of Fox's execution.

By default, Fox runners do not have a reporter assigned to it. But Fox does
provide a couple reporters:

- ``FOXStandardReporter`` reports in a rspec-like dot reporter.
- ``FOXDebugReporter`` reports more information about the execution.

The default reporter can be changed by setting it from the instance
``FOXAssert`` uses: ``[[FOXRunner assertInstance] setReporter:reporter]``.

.. _delegate: https://developer.apple.com/library/ios/documentation/general/conceptual/CocoaEncyclopedia/DelegatesandDataSources/DelegatesandDataSources.html


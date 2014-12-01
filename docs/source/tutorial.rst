.. highlight:: objective-c

Tutorial
========

Starting with an Example
------------------------

Throughout this tutorial, we'll cover the basics of writing property tests.  To
better understand property tests, let's start with some example-based ones
first::

    - (void)testSort {
        NSArray *sortedNumbers = [MySorter sortNumbers:@[@5, @2, @1]];
        XCTAssertObjectsEqual(sortedNumbers, @[@1, @2, @5]);
    }

This is a simple example test about sorting numbers. Let's break down parts of
this test and see how Fox rebuilds it up::

    - (void)testSort {
        // inputs
        NSArray *input = @[@5, @2, @1];
        // subject under test
        NSArray *sortedNumbers = [MySorter sortNumbers:input];
        // assertion
        XCTAssertObjectsEqual(sortedNumbers, @[@1, @2, @5]);
    }

Fox takes these parts and separates them.

- Inputs are produced using :ref:`generators`. Generators describe the type of
  data to generate.
- Subject under test remains the same
- The assertion is based on logical statements of the subject and/or based on
  the generated inputs.

Let's see how we can convert them to Fox property tests.

Converting to Property Tests
----------------------------

To convert the sort test into the given property, we can describe the intrinsic
property of its outputs. For sorting, the resulting output should have the
smallest elements in the start of the array and every element afterwards should
be greater than or equal to the element before it::

    - (void)testSortBySmallestNumber {
        id<FOXGenerator> arraysOfIntegers = FOXArray(FOXIntegers());
        FOXAssert(FOXForAll(arraysOfIntegers, ^BOOL(NSArray *integers) {
            // subject under test
            NSArray *sortedNumbers = [MySorter sortNumbers:integers];
            // assertion
            NSNumber *previousNumber = nil;
            for (NSNumber *n in sortedNumbers) {
                if (!previousNumber || [previousNumber integerValue] <= [n integerValue]) {
                    previousNumber = n;
                } else {
                    return NO; // fail
                }
            }
            return YES; // succeed
        }));
    }

Let's break that down:

- ``FOXIntegers`` is a generator that describes how to produce random integers
  (NSNumbers).
- ``FOXArray`` is a generator that describes how to generate arbitrary arrays.
  It takes another generator as an argument. In this case, we're giving it an
  integer generator so this will generate randomly sized array of random
  integers.
- ``FOXForAll`` is describing a property that should always hold true. It takes
  two arguments, the generator to produce and a block on how to assert against
  the given generated input.
- ``FOXAssert`` is how Fox asserts against properties. It will raise an
  exception if a property does not hold.

The test can be read as:

    Assert that for all array of integers named ``integer``, sorting
    ``integers`` should produce ``sortedNumbers``. ``sortedNumbers`` is an
    array where the first number is the smallest and subsequent elements are
    greater than or equal to the element that preceeds it.

There are other properties of the code that can be described as properties.
Such as the number of inputs is equal to the number of outputs::

    - (void)testSortMaintainsSize {
        FOXAssert(FOXForAll(FOXArray(FOXIntegers()), ^BOOL(NSArray *integers) {
            NSArray *sortedNumbers = [MySorter sortNumbers:integers];
            return integers.count == sortedNumbers.count;
        }));
    }

And each input element appears in the output element::

    - (void)testSortPreservesAllElements {
        FOXAssert(FOXForAll(FOXArray(FOXIntegers()), ^BOOL(NSArray *integers) {
            NSMutableArray *unseenInputs = [integers mutableCopy];
            NSArray *sortedNumbers = [MySorter sortNumbers:integers];
            for (NSNumber *n in sortedNumbers) {
                if ([unseenInputs containsObject:n]) {
                    [unseenInputs removeObject:n];
                } else {
                    return NO;
                }
            }
            return unseenInputs.count == 0;
        }));
    }

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


Testing Stateful APIs
---------------------

Now this is all well and good for testing purely functional APIs - where the
same input produces the same output. Let's look at testing stateful APIs.

Before we start. Let's talk about the conceptual model Fox can use to verify
stateful APIs. Using the existing system of :ref:`generators`, we can model
**API calls as data**.

As a simple case, let's test a `Queue`_. We can model a series of API calls as
so:

- ``[queue add:1]``
- ``[queue remove] // => 1``
- ``[queue add:2]``
- ``[queue add:3]``
- ``[queue remove] // => 2``
- ``[queue remove] // => 3``

But generating a series of API calls isn't enough. Fox needs more information
about the API:

- What API calls a valid to make at any particular time?
- What assertions should between after any API call?

This is done by describing a `state machine`_.

.. _Queue: http://en.wikipedia.org/wiki/Queue_(abstract_data_type)
.. _state machine: http://en.wikipedia.org/wiki/Finite-state_machine


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
        XCTAssertEqualObjects(sortedNumbers, @[@1, @2, @5]);
    }

This is a simple example test about sorting numbers. Let's break down parts of
this test and see how Fox rebuilds it up::

    - (void)testSort {
        // inputs
        NSArray *input = @[@5, @2, @1];
        // behavior to test
        NSArray *sortedNumbers = [MySorter sortNumbers:input];
        // assertion
        XCTAssertEqualObjects(sortedNumbers, @[@1, @2, @5]);
    }

Fox takes these parts and separates them.

- Inputs are produced using :ref:`generators`. Generators describe the type of
  data to generate.
- Behavior to test remains the same.
- The assertion is based on logical statements of the subject and/or based on
  the generated inputs. The assertions as usually describe properties of the
  subject under test.

Let's see how we can convert them to Fox property tests.

Converting to Property Tests
----------------------------

To convert the sort test into the given property, we can describe the intrinsic
property of the code under test.

For sorting, the resulting output should have the smallest elements in the
start of the array and every element afterwards should be greater than or equal
to the element before it::

    - (void)testSortBySmallestNumber {
        id<FOXGenerator> arraysOfIntegers = FOXArray(FOXInteger());
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

- ``FOXInteger`` is a :ref:`generator` that describes how to produce random integers
  (NSNumbers).
- ``FOXArray`` is a :ref:`generator` that describes how to generate arbitrary arrays.
  It takes another generator as an argument. In this case, we're giving it an
  integer generator so this will generate randomly sized array of random
  integers.
- ``FOXForAll`` describes a property that should always hold true. It takes
  two arguments, the generator to produce and a block on how to assert against
  the given generated input.
- ``FOXAssert`` is how Fox asserts against properties. It will raise an
  exception if a property does not hold.

The test can be read as:

    Assert that for all array of integers named ``integer``, sorting
    ``integers`` should produce ``sortedNumbers``. ``sortedNumbers`` is an
    array where the first number is the smallest and subsequent elements are
    greater than or equal to the element that preceeds it.

Diagnosing Test Failures
------------------------

The interesting feature of Fox occurs only when tests fail. Let's write a code
that will fail the property we just wrote::

    + (NSArray *)sortNumbers:(NSArray *)numbers {
        NSMutableArray *sortedNumbers = [[numbers sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
        if (sortedNumbers.count >= 5) {
            id tmp = sortedNumbers[0];
            sortedNumbers[0] = sortedNumbers[1];
            sortedNumbers[1] = tmp;
        }
        return sortedNumbers;
    }

Some nefarious little code we added there! We run again we get to see Fox work::

    Property failed with: ( 0, 0, 0, 0, "-1" ) 
    Location:   // /Users/jeff/workspace/FoxExample/FoxExampleTests/FoxExampleTests.m:41
      FOXForAll(arraysOfIntegers, ^BOOL(NSArray *integers) {
       NSArray *sortedNumbers = [self sortNumbers:integers];
       NSNumber *previousNumber = ((void *)0);
       for (NSNumber *n in sortedNumbers) {
       if (!previousNumber || [previousNumber integerValue] <= [n integerValue]) {
       previousNumber = n;
       }
       else {
       return __objc_no;
       }
       }
       return __objc_yes;
       }
      );
      
    RESULT: FAILED
     seed: 1417500369
     maximum size: 200
     number of tests before failing: 8
     size that failed: 7
     shrink depth: 8
     shrink nodes walked: 52
     value that failed: (
        "-3",
        "-3",
        1,
        "-2",
        "-7",
        "-5"
    )
     smallest failing value: (
        0,
        0,
        0,
        0,
        "-1"
    )

The first line describes the smallest failing example that failed. It's placed there for convenience::

    Property failed with: ( 0, 0, 0, 0, "-1" ) 

The rest of the first half of the failure describes the location and property that failed.

The latter half of the failure describes specifics on how the smallest failing example was reached:

- ``seed`` is the random seed that was used to generate the series of tests to
  run. See :ref:`Configuring Test Generation` for more information
- ``maximum size`` is the maximum size hint that Fox used. See
  :ref:`Configuring Test Generation` for more information.
- ``number of tests before failing`` describes how many tests were generated
  before the failing test was generated. Mostly for technical curiosity.
- ``size that failed`` describes the size that was used to generate the
  original failing test case. The size dicates the general size of the data
  generated (eg - larger numbers and bigger arrays).
- ``shrink depth`` describes how many "changes" performed to shrink the
  original failing test to produce the smallest one. Mostly for technical
  curiosity.
- ``shrink nodes walked`` describes how many variations Fox performed to
  produce the smallest failing test.
- ``value that failed`` the original generated value that failed the property.
  This is before any shrinking.
- ``smallest failing value`` the smallest generated value that still fails the
  property. This is identical to the value on the first line of this failure description.

So what happened? Fox generates random data until a failure occurs. Once a
failure occurs, Fox starts the shrinking process. The shrinking behavior is
generator-dependent, but generally alter the data towards the "zero" value:

- For integers, that means moving towards 0 value.
- For arrays, each element shrinks as well as the number of elements
  moves towards zero.

Each time the value is shrunk, Fox will verify it against the property to
ensure the test still fails.  This is a brute-force process of elimination 
is an effective way to drop irrevelant noise that random data generation
typically produces.

Comparing the original failure and the shunk failure we can observe that the
second-to-last element had some significance since it failed to shrink all the
way to zero like the other elements. It's also worth noting that just because a
value has been shrunk to zero doesn't exclude it's potential significance, but
it is usually less likely to be significant.


Adding More Properties
----------------------

There are other properties of the code that can be described as properties.
Let's look a few for illustrative purposes. A simplier property is the number
of inputs is equal to the number of outputs::

    - (void)testSortMaintainsSize {
        FOXAssert(FOXForAll(FOXArray(FOXInteger()), ^BOOL(NSArray *integers) {
            NSArray *sortedNumbers = [MySorter sortNumbers:integers];
            return integers.count == sortedNumbers.count;
        }));
    }

Or all input element appears in the output element::

    - (void)testSortPreservesAllElements {
        FOXAssert(FOXForAll(FOXArray(FOXInteger()), ^BOOL(NSArray *integers) {
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


Testing Stateful APIs
---------------------

Now this is all well and good for testing purely functional APIs - where the
same input produces the same output. What's more interesting is testing
stateful APIs.

Before we start, let's talk about the conceptual model Fox uses to verify
stateful APIs. Using the existing system of :ref:`generators`, we can model
**API calls as data**.

As a simple case, let's test a `Queue`_. We can add and remove objects to it.
Removing objects returns the first item in the Queue:

- ``[queue add:1]``
- ``[queue remove] // => returns 1``
- ``[queue add:2]``
- ``[queue add:3]``
- ``[queue remove] // => returns 2``
- ``[queue remove] // => returns 3``

Just generating a series of API calls isn't enough. Fox needs more information
about the API:

- What API calls a valid to make at any particular time?
- What assertions should between after any API call?

This is done by describing a `state machine`_. In basic terms, a state machine
is two parts: state and transitions. State indicates data that persists between
transitions. It dictates **what transitions are available at any give time**.

.. _Queue: http://en.wikipedia.org/wiki/Queue_(abstract_data_type)
.. _state machine: http://en.wikipedia.org/wiki/Finite-state_machine


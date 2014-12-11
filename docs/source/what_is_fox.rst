.. highlight:: objective-c

What is Fox?
============

Fox is a port of the property-based testing tool `test.check`_ for Objective-C
and Swift.

`QuickCheck`_ inspired Property-Based Testing Tools are test generators. These
tools allow you to describe a property of your program that should always hold
true instead of writing hand-crafted test cases. A pseudo-code example would
be::

    // pseudocode: A property for the sort() function
    property := ForAll(xs where xs is an Array of Unsigned Integers){
        // perform action
        sorted_numbers := sort(xs)
        // verify that sorted_numbers is in ascending order
        i := 0
        for n in sorted_numbers {
            if i <= n {
                i = n
            } else {
                return FAILURE
            }
        }
        return SUCCESS
    }

This example tests a sort function. Fox will generate tests based on the
requirements of ``xs`` (any array of unsigned integers) to find a failing
example that causes a FAILURE.

In the mathematical sense, Fox is a weak proof checker of a property where the
tool tries to assert the property is valid by randomly generating data to find
a counter-example.

.. _test.check: https://github.com/clojure/test.check
.. _QuickCheck: https://www.haskell.org/haskellwiki/Introduction_to_QuickCheck2


Shrinking Failures
------------------

A benefit of Fox over purely random data generation is Shrinking.  An informed
random generation is done by size.  This allows the tool to reduce the
counter-example to a smaller data set without having a user manually separate
thes signal from the noise in the randomly generated data.

For example, if a ``sort()`` implementation failed with an exception when
reading 9s. Fox might generate this value to provoke the failure::

    xs = @[@1, @5, @9, @3, @5] // fails

And then proceed to shrink ``xs`` by trying smaller permutations::

    xs = @[@5, @9, @3, @5] // still fails
    xs = @[@9, @3, @5] // fails
    xs = @[@3, @5] // passed
    xs = @[@9, @5] // fails
    xs = @[@9] // fails

Fox does this automatically whenever a failure occurs. This is valuable instead
of having to manually debug a failure when random data generation is used.

Ready to get started? :doc:`Install Fox </installation>`.


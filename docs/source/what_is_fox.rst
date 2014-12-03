.. highlight:: objective-c

What is Fox?
============

Fox is a port of the property-based testing tool `test.check`_ (decendant of
QuickCheck).

Property-based Testing Tools, especially ones inspired from QuickCheck, are
test generators. Instead of hand-crafted test cases, these tools allow you to
describe a property of your program that should always hold true. An example
pseudo-code would be::

    // pseudocode: A property for the sort() function
    ForAll(xs where xs is an Array of Unsigned Integers){
        // perform action
        sorted_numbers := sort(xs)
        // verify that sorted_numbers is in ascending order
        i := 0
        for n in sorted_numbers {
            if i <= n {
                i = n
            } else {
                return FAIL
            }
        }
        return SUCCESS
    }

Which tests a sort function. The property testing tool will generate examples
based on the requirements (of ``xs``) to try and find a failling example.

In the mathematical sense, a property testing tool is a weak proof of a
property where the tool tries to assert the property is valid by randomly
generating a counter-example.

Shrinking Failures
------------------

The benefit of Fox over purely random data generation is Shrinking.  Instead of
purely random data generation, an informed random generation is done by size.
This allows the tool to reduce the counter-example to a smaller data set.

For example, if a ``sort()`` implementation failed with an exception when
reading 9s. Fox might have generated this value that provoked the failure::

    xs = @[@1, @5, @9, @3, @5]

And then proceed to shrink ``xs`` to::

    xs = @[@9]

This reduces the amount of manual debugging to determine the smallest example
that provokes the failure.

.. _test.check: https://github.com/clojure/test.check
.. _Haskell QuickCheck: https://www.haskell.org/haskellwiki/Introduction_to_QuickCheck2


.. highlight:: objective-c
.. _Generator:
.. _Generators:

==========
Generators
==========

Generators are the core of Fox. They specify directed random data creation.
This means generators know how to create the given data and how to shrink it.

In technical terms, all generators conform to the ``FOXGenerator`` protocol.
All generators return a lazy :ref:`rose tree` for consumption by the :doc:`Fox
runner </runner>`.

The power of generators are their composability. Shrinking is provided for
*free* if you compose with Fox's built-in generators. Of course, you can
provide custom shrinking strategies as you needed. In fact, most of Fox's
built-in generators are composed on top of ``FOXChoose``.

For the typed programming enthusiast, generators are expected to conform to
this type:

    ``(id<FOXRandom>, uint32_t) -> FOXRoseTree<U>`` where ``U`` is an
    Objective-C object.

There are few special cases to this rule. For example, ``FOXAssert`` expects
``FOXRoseTree<FOXPropertyResult>`` which ``FORForAll`` produces.

.. info::
    For Haskell programmers, Fox is a decendant to Haskell's QuickCheck 2.
    Generators are monadic type which combine generation and shrinking.

.. _Built-in Generators:

Built-in Generators
===================

.. NOTICE: if you're updating this reference. Remember to update the README.

Here are the list of built-in generators that Fox provides. They are either
generators of a particular data type or provide computation on top of other
generators.

Data Generators
---------------

There are many data generators provided for generating data. Most of these
generators shrink to zero:

 - Numerically zero (or as close as possible)
 - Empty collection (or at least shrunk items)

=================================== ================ =============
Function                             Generates        Description
=================================== ================ =============
FOXInteger                           NSNumber *       Generates random integers.
FOXPositiveInteger                   NSNumber *       Generates random zero or positive integers.
FOXNegativeInteger                   NSNumber *       Generates random zero or negative integers.
FOXStrictPositiveInteger             NSNumber *       Generates random positive integers (non-zero).
FOXStrictNegativeInteger             NSNumber *       Generates random negative integers (non-zero).
FOXChoose                            NSNumber *       Generates random integers between the given range (inclusive).
FOXFloat                             NSNumber *       Generates random floats.
FOXReturn                            id               Always returns the given value. Does not shrink.
FOXTuple                             NSArray *        Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
FOXTupleOfGenerators                 NSArray *        Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
FOXArray                             NSArray *        Generates random variable-sized arrays of generated values.
FOXArrayOfSize                       NSArray *        Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
FOXArrayOfSizeRange                  NSArray *        Generates random variable-sized arrays of generated values. Array size is within the given range (inclusive).
FOXDictionary                        NSDictionary *   Generates random dictionries of generated values. Keys are known values ahead of time. Specified in `@{<key>: <generator>}` form.
FOXSet                               NSSet *          Generates random sets of a given generated values.
FOXCharacter                         NSString *       Generates random 1-length sized character string. May be an unprintable character.
FOXAlphabetCharacter                 NSString *       Generates random 1-length sized character string. Only generates alphabetical letters.
FOXNumericCharacter                  NSString *       Generates random 1-length sized character string. Only generates digits.
FOXAlphanumericCharacter             NSString *       Generates random 1-length sized character string. Only generates alphanumeric.
FOXString                            NSString *       Generates random variable length strings. May be an unprintable string.
FOXStringOfSize                      NSString *       Generates random fixed length strings. May be an unprintable string.
FOXStringOfSizeRange                 NSString *       Generates random length strings within the given range (inclusive). May be an unprintable string.
FOXAsciiString                       NSString *       Generates random variable length strings. Only generates ascii characters.
FOXAsciiStringOfSize                 NSString *       Generates random fixed length strings. Only generates ascii characters.
FOXAsciiStringOfSizeRange            NSString *       Generates random variable length strings within the given range (inclusive). Only generates ascii characters.
FOXAlphabeticalString                NSString *       Generates random variable length strings. Only generates alphabetical characters.
FOXAlphabeticalStringOfSize          NSString *       Generates random fixed length strings. Only generates alphabetical characters.
FOXAlphabeticalStringOfSizeRange     NSString *       Generates random variable length strings within the given range (inclusive). Only generates alphabetical characters.
FOXAlphanumericalString              NSString *       Generates random variable length strings. Only generates alphabetical characters.
FOXAlphanumericalStringOfSize        NSString *       Generates random fixed length strings. Only generates alphanumeric characters.
FOXAlphanumericalStringOfSizeRange   NSString *       Generates random variable length strings within the given range (inclusive). Only generates alphanumeric characters.
FOXNumericalString                   NSString *       Generates random variable length strings. Only generates numeric characters.
FOXNumericalStringOfSize             NSString *       Generates random fixed length strings. Only generates numeric characters.
FOXNumericalStringOfSizeRange        NSString *       Generates random variable length strings within the given range (inclusive). Only generates numeric characters.
FOXSimpleType                        id               Generates random simple types. A simple type does not compose with other types. May not be printable.
FOXPrintableSimpleType               id               Generates random simple types. A simple type does not compose with other types. Ensured to be printable.
FOXCompositeType                     id               Generates random composite types. A composite type composes with the given generator.
=================================== ================ =============

Computation Generators
----------------------

Also, you can compose some computation work on top of data generators. The resulting
generator adopts the same shrinking properties as the original generator.

=========================   ============
Function                    Description
=========================   ============
FOXMap                      Applies a block to each generated value.
FOXBind                     Applies a block to the lazy tree that the original generator creates. See Building Generators section for more information.
FOXSized                    Encloses the given block to create generator that is dependent on the size hint generators receive when generating values.
FOXSuchThat                 Returns each generated value iff it satisfies the given block. If the filter excludes more than 10 values in a row, the resulting generator assumes it has reached maximum shrinking.
FOXSuchThatWithMaxTries     Returns each generated value iff it satisfies the given block. If the filter excludes more than the given max tries in a row, the resulting generator assumes it has reached maximum shrinking.
FOXOneOf                    Returns generated values by randomly picking from an array of generators. Shrinking will move towards the lower-indexed generators in the array.
FOXForAll                   Asserts using the block and a generator and produces test assertion results (FOXPropertyResult). Shrinking tests against smaller values of the given generator.
FOXForSome                  Like FOXForAll, but allows the assertion block to "skip" potentially invalid test cases.
FOXCommands                 Generates arrays of FOXCommands that satisfies a given state machine.
FOXExecuteCommands          Generates arrays of FOXExecutedCommands that satisfies a given state machine and executed against a subject. Can be passed to FOXExecutedSuccessfully to verify if the subject conforms to the state machine.
=========================   ============

.. warning:: Using ``FOXSuchThat`` and ``FOXSuchThatWithMaxTries`` are "filter"
             generators and can lead to significant waste in test generation by
             Fox. While it gives you the most flexibility the kind of generated
             data, it is the most computationally expensive. Use other
             generators when possible.

.. _Building Custom Generators:

Building Custom Generators
==========================

It's easy to compose the built-in generator to build generators for custom data
types we have. Let's say we want to generate random permutations of a Person
class::

    // value object. Implementation assumed
    @interface Person : NSObject
    @property (nonatomic) NSString *firstName;
    @property (nonatomic) NSString *lastName;
    @end

We can represent this Person data using by generating an array of values or
dictionary of values. Here's how it looks using a dictionary in an property
assertion::

    id<FOXGenerator> dictionaryGenerator = FOXDictionary(@{
        @"firstName": FOXAlphabeticalString(),
        @"lastName": FOXAlphabeticalString()
    });
    FOXAssert(FOXForAll(dictionaryGenerator, ^BOOL(NSDictionary *data) {
        Person *person = [[Person alloc] init];
        person.firstName = data[@"firstName"];
        person.lastName = data[@"lastName"];
        // assert with person
    }));

But we want this to be reusable. Using ``FOXMap``, we can create a new
generator that is based on the ``dictionaryGenerator``::

    // A new generator that creates random person
    id<FOXGenerator> AnyPerson(void) {
        id<FOXGenerator> dictionaryGenerator = FOXDictionary(@{
            @"firstName": FOXAlphabeticalString(),
            @"lastName": FOXAlphabeticalString()
        });
        return FOXMap(dictionaryGenerator, ^id(NSDictionary *data) {
            Person *p = [[Person alloc] init];
            p.firstName = data[@"firstName"];
            p.lastName = data[@"lastName"];
            return p;
        });
    }

And we can then use is like any other generator::

    FOXAssert(FOXForAll(AnyPerson(), ^BOOL(Person *person) {
        // assert with person
    }));

You can see the :ref:`reference <Built-in Generators>` for all the generators.
The most common generators can be creating using the provided mappers.

.. _How Shrinking Works:

How Shrinking Works
===================

Generators are just functions that accept a random number generator and a size
hint and return a :ref:`rose tree` of values.

Rose trees sound fancy, but they are generic trees with an arbitrary number of
branches. Each node in the tree represents a value. Fox generators create rose
trees instead of individual values. This allows the :doc:`runner </runner>` to
shrink the value by traversing through the children of the tree.

The main shrinking implementation Fox uses are for for integers (via
``FOXChoose``). If a 4 was generated, the rose tree that ``FOXChoose``
generates would look like this:

.. image:: images/rose-tree-4.png

Where the children of each node represents a smaller value that its parent. Fox
will walk depth-first search through this tree when a test fails to shrink to
the smallest value.

Based on the diagram, the algorithm for shrinking integers prefers:

- Reducing to zero immediately
- Reducing to 50% of the original value
- Reducing the value by 1

While this makes it more expensive to find larger integers (because of the
redundent checking of zero), it is generally more common to immediately shrink
to the smallest value.

.. _Building Generators with Custom Shrinking:

Writing Generators with Custom Shrinking
========================================

.. warning::
    **This is significantly more complicated than composing generators**, which
    is what you want the majority of the time. Composing existing generators
    will also provide shrinking for free.

.. warning::
    This section assumes function programming concepts. It's worth reading up
    on function composition, map/reduce, and lazy computation.

It is worth reading up on :ref:`How Shrinking Works` before proceeding.

Let's write a custom integer generator that shrinks to 10 instead of zero. We
won't be using any thing built on top of ``FOXChoose`` for demonstrative
purposes.

Step one, we can easily always generate 10 by returning a child-less rose tree::

    id<FOXGenerator> MyInteger(void) {
        FOXGenerate(^FOXRoseTree *(id<FOXRandom> random, NSUInteger size) {
            return [[FOXRoseTree alloc] initWithValue:@10];
        });
    }

``FOXGenerate`` is an easy way to create a generator without having to create
an object that conformed to ``FOXGenerator``. The block is the method body of
the one method that the protocol requires.

This is infact what ``FOXReturn`` does. However, we don't get any
randominess::

    // FOXSample generates 10 random values using the given generator.
    FOXSample(MyInteger()); // => @[@3];

So let's use the random number generator provided. We'll also use the size to
dictate the size we want::

    id<FOXGenerator> MyInteger(void) {
        FOXGenerate(^FOXRoseTree *(id<FOXRandom> random, NSUInteger size) {
            NSInteger lower = -((NSInteger)size);
            NSInteger upper = (NSInteger)size;
            NSInteger randomInteger = [random randomIntegerWithinMinimum:lower
                                                              andMaximum:upper];
            return [[FOXRoseTree alloc] initWithValue:@(randomInteger)];
        });
    }

We now generate random integers! But we still don't have any shrinking::

    // Random integers
    FOXSample(MyInteger());
    // => @[@-30, @103, @188, @-184, @-22, @-118, @147, @-186, @-128, @-68]

    // FOXSampleShrinking takes the first 10 values of the rose tree.
    // The first value is the generated value. Subsequent values are
    // shrinking values from the first one.
    FOXSampleShrinking(MyInteger()) // => @[@-8]; there's no shrinking

Let's add a simple shrinking mechanism, we can populate the children of the
rose tree we return::

    id<FOXGenerator> MyInteger(void) {
        FOXGenerate(^FOXRoseTree *(id<FOXRandom> random, NSUInteger size) {
            NSInteger lower = -((NSInteger)size);
            NSInteger upper = (NSInteger)size;
            NSInteger randomInteger = [random randomIntegerWithinMinimum:lower
                                                              andMaximum:upper];
            id<FOXSequence> children = [FOXSequence sequenceFromArray:@[[[FOXRoseTree alloc] initWithValue:@10]]];
            return [[FOXRoseTree alloc] initWithValue:@(randomInteger)
                                             children:children];
        });
    }
    // Shrinking once
    FOXSampleShrinking(MyInteger()) // => @[@-8, @10];

Of course, we don't properly handle shrinking for all variations.
``FOXSequence`` is a port of `Clojure's sequence abstraction`_. They provide
laziness for Fox's rose tree.

.. _Clojure's sequence abstraction: http://clojure.org/sequences


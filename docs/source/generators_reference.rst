
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
Function                            Generates        Description
=================================== ================ =============
FOXInteger                          NSNumber *       Generates random integers.
FOXPositiveInteger                  NSNumber *       Generates random zero or positive integers.
FOXNegativeInteger                  NSNumber *       Generates random zero or negative integers.
FOXStrictPositiveInteger            NSNumber *       Generates random positive integers (non-zero).
FOXStrictNegativeInteger            NSNumber *       Generates random negative integers (non-zero).
FOXChoose                           NSNumber *       Generates random integers between the given range (inclusive).
FOXFloat                            NSNumber *       Generates random floats.
FOXDouble                           NSNumber *       Generates random doubles.
FOXDecimalNumber                    NSNumber *       Generates random decimal numbers.
FOXReturn                           id               Always returns the given value. Does not shrink.
FOXTuple                            NSArray *        Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
FOXTupleOfGenerators                NSArray *        Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
FOXArray                            NSArray *        Generates random variable-sized arrays of generated values.
FOXArrayOfSize                      NSArray *        Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
FOXArrayOfSizeRange                 NSArray *        Generates random variable-sized arrays of generated values. Array size is within the given range (inclusive).
FOXDictionary                       NSDictionary *   Generates random dictionries of generated values. Keys are known values ahead of time. Specified in `@{<key>: <generator>}` form.
FOXSet                              NSSet *          Generates random sets of a given generated values.
FOXCharacter                        NSString *       Generates random 1-length sized character string. May be an unprintable character.
FOXAlphabetCharacter                NSString *       Generates random 1-length sized character string. Only generates alphabetical letters.
FOXNumericCharacter                 NSString *       Generates random 1-length sized character string. Only generates digits.
FOXAlphanumericCharacter            NSString *       Generates random 1-length sized character string. Only generates alphanumeric.
FOXString                           NSString *       Generates random variable length strings. May be an unprintable string.
FOXStringOfSize                     NSString *       Generates random fixed length strings. May be an unprintable string.
FOXStringOfSizeRange                NSString *       Generates random length strings within the given range (inclusive). May be an unprintable string.
FOXAsciiString                      NSString *       Generates random variable length strings. Only generates ascii characters.
FOXAsciiStringOfSize                NSString *       Generates random fixed length strings. Only generates ascii characters.
FOXAsciiStringOfSizeRange           NSString *       Generates random variable length strings within the given range (inclusive). Only generates ascii characters.
FOXAlphabeticalString               NSString *       Generates random variable length strings. Only generates alphabetical characters.
FOXAlphabeticalStringOfSize         NSString *       Generates random fixed length strings. Only generates alphabetical characters.
FOXAlphabeticalStringOfSizeRange    NSString *       Generates random variable length strings within the given range (inclusive). Only generates alphabetical characters.
FOXAlphanumericalString             NSString *       Generates random variable length strings. Only generates alphabetical characters.
FOXAlphanumericalStringOfSize       NSString *       Generates random fixed length strings. Only generates alphanumeric characters.
FOXAlphanumericalStringOfSizeRange  NSString *       Generates random variable length strings within the given range (inclusive). Only generates alphanumeric characters.
FOXNumericalString                  NSString *       Generates random variable length strings. Only generates numeric characters.
FOXNumericalStringOfSize            NSString *       Generates random fixed length strings. Only generates numeric characters.
FOXNumericalStringOfSizeRange       NSString *       Generates random variable length strings within the given range (inclusive). Only generates numeric characters.
FOXSimpleType                       id               Generates random simple types. A simple type does not compose with other types. May not be printable.
FOXPrintableSimpleType              id               Generates random simple types. A simple type does not compose with other types. Ensured to be printable.
FOXCompositeType                    id               Generates random composite types. A composite type composes with the given generator.
FOXAnyObject                        id               Generates random simple or composite types.
FOXAnyPrintableObject               id               Generates random printable simple or composite types.
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
FOXResize                   Overrides the given generator's size parameter with the specified size. Prevents shrinking.
FOXOptional                 Creates a new generator that has a 25% chance of returning `nil` instead of the provided generated value.
FOXFrequency                Dispatches to one of many generators by probability. Takes an array of tuples (2-sized array) - `@[@[@probability_uint, generator]]`. Shrinking follows whatever generator is returned.
FOXSized                    Encloses the given block to create generator that is dependent on the size hint generators receive when generating values.
FOXSuchThat                 Returns each generated value iff it satisfies the given block. If the filter excludes more than 10 values in a row, the resulting generator assumes it has reached maximum shrinking.
FOXSuchThatWithMaxTries     Returns each generated value iff it satisfies the given block. If the filter excludes more than the given max tries in a row, the resulting generator assumes it has reached maximum shrinking.
FOXOneOf                    Returns generated values by randomly picking from an array of generators. Shrinking is dependent on the generator chosen.
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

.. _Debugging Functions:

Debugging Functions
-------------------

Fox comes with a handful of functions that can help you diagnose generator problems.

============================ ============
Function                     Description
============================ ============
FOXSample                    Samples 10 values that generator produces.
FOXSampleWithCount           Samples a number of values that a generator produces.
FOXSampleShrinking           Samples 10 steps of shrinking from a value that a generator produces.
FOXSampleShrinkingWithCount  Samples a number of steps of shrinking from a value that a generator produces.
============================ ============


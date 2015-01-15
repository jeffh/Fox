.. highlight:: objective-c

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

.. c:function:: id<FOXGenerator> FOXInteger(void)

    Generates random integers boxed as a NSNumber. Shrinks to 0::

        FOXInteger()
        // example generations: 0, -1, 1

.. c:function:: id<FOXGenerator> FOXPositiveInteger(void)

    Generates random positive integers boxed as a NSNumber. Shrinks to 0::

        FOXPositiveInteger()
        // example generations: 0, 1, 2

.. c:function:: id<FOXGenerator> FOXNegativeInteger(void)

    Generates random negative integers boxed as a NSNumber. Shrinks to 0::

        FOXNegativeInteger()
        // example generations: 0, -1, -2

.. c:function:: id<FOXGenerator> FOXStrictPositiveInteger(void)

    Generates random positive integers boxed as a NSNumber. Shrinks to 1::

        FOXStrictPositiveInteger()
        // example generations: 1, 2, 3

.. c:function:: id<FOXGenerator> FOXStrictNegativeInteger(void)

    Generates random negative integers boxed as a NSNumber. Shrinks to -1::

        FOXStrictNegativeInteger()
        // example generations: -1, -2, -3

.. c:function:: id<FOXGenerator> FOXNonZeroInteger(void)

    Generates random negative integers boxed as a NSNumber. Shrinks to 1. Does
    not emit 0::

        FOXNonZeroInteger()
        // example generations: -1, 2, -3

.. c:function:: id<FOXGenerator> FOXChoose(NSNumber *miniumNumber, NSNumber *maximumNumber)

    Generates random integers boxed as a NSNumber within the given range
    (inclusive). Shrinks to miniumNumber. The miniumNumber can never be greater
    than maximumNumber::

        FOXChoose(@5, @10)
        // example generations: 5, 6, 7

.. c:function:: id<FOXGenerator> FOXFloat(void)

    Generates random floating point numbers that conform to the IEEE 754
    standard in a boxed NSNumber. Shrinks towards zero by shrinking the float's
    exponent and mantissa::

        FOXFloat()
        // example generations: 0, 3.436027e+10, -9.860766e-32

    The generator **does not** generate negative zeros or negative infinities.
    It is possible to generate positive infinity and NaNs, but is highly
    unlikely.

.. c:function:: id<FOXGenerator> FOXDouble(void)

    Generates random doubles that conform to the IEEE 754 standard in a boxed
    NSNumber. Shrinks towards zero by shrinking the double's exponent and
    mantissa::

        FOXDouble()
        // example generations: 0, 6.983507489299851e-251, -3.101300322905138e-266

    The generator **does not** generate negative zeros or negative infinities.
    It is possible to generate positive infinity and NaNs, but is highly
    unlikely.

.. c:function:: id<FOXGenerator> FOXDecimalNumber(void)

    Generates random decimal numbers. Shrinks towards zero by shrinking the
    mantissa and exponent.

    The generator **does not** generate NaNs::

        FOXDecimalNumber()
        // example generations: 0, -192000000000000000000000000000000000000000000, 790000000000000000000000000000000000000000000000000000000000000000000000000000

.. c:function:: id<FOXGenerator> FOXFamousInteger(void)

    Generates random integers boxed as a NSNumber. Shrinks to 0. Unlike
    :c:func:`FOXInteger`, this generator increases the likelihood of generating
    extreme values (INT_MAX, INT_MIN)::

        FOXFamousInteger()
        // example generations: 0, -1, 32767, -32767

    It is not recommended to use this generator to produce collections.

.. c:function:: id<FOXGenerator> FOXFamousPositiveInteger(void)

    Generates random positive integers boxed as a NSNumber. Shrinks to 0.
    Unlike :c:func:`FOXPositiveInteger`, this generator increases the likelihood
    of generating extreme values (INT_MAX)::

        FOXFamousPositiveInteger()
        // example generations: 0, -1, 32767

    It is not recommended to use this generator to produce collections.

.. c:function:: id<FOXGenerator> FOXFamousNegativeInteger(void)

    Generates random negative integers boxed as a NSNumber. Shrinks to 0.
    Unlike :c:func:`FOXNegativeInteger`, this generator increases the likelihood
    of generating extreme values (INT_MIN)::

        FOXNegativeInteger()
        // example generations: 0, -1, -2, -32767 

    It is not recommended to use this generator to produce collections.

.. c:function:: id<FOXGenerator> FOXFamousStrictPositiveInteger(void)

    Generates random positive integers boxed as a NSNumber. Shrinks to 1.
    Unlike :c:func:`FOXStrictPositiveInteger`, this generator increases the
    likelihood of generating extreme values (INT_MAX)::

        FOXFamousStrictPositiveInteger()
        // example generations: 1, 5, 32767

    It is not recommended to use this generator to produce collections.

.. c:function:: id<FOXGenerator> FOXFamousStrictNegativeInteger(void)

    Generates random negative integers boxed as a NSNumber. Shrinks to -1.
    Unlike :c:func:`FOXStrictPositiveInteger`, this generator increases the
    likelihood of generating extreme values (INT_MIN)::

        FOXFamousStrictNegativeInteger()
        // example generations: -1, -2, -32767

    It is not recommended to use this generator to produce collections.

.. c:function:: id<FOXGenerator> FOXFamousNonZeroInteger(void)

    Generates random negative integers boxed as a NSNumber. Shrinks to 1. Does
    not emit 0. Unlike :c:func:`FOXNonZeroInteger`, this generator increases the
    likelihood of generating extreme values (INT_MAX, INT_MIN)::

        FOXFamousNonZeroInteger()
        // example generations: -4, 32767, -32767

    It is not recommended to use this generator to produce collections.

.. c:function:: id<FOXGenerator> FOXFamousFloat(void)

    Generates random floating point numbers that conform to the IEEE 754
    standard in a boxed NSNumber. Shrinks towards zero by shrinking the float's
    exponent and mantissa. Unlike :c:func:`FOXFloat`, this generator increases
    the likelihood of generating extreme values (FLT_MAX, -FLT_MAX, INFINITY,
    -INFINITY, -0, NaN)::

        FOXFamousFloat()
        // example generations: 0, 3.436027e+10, -9.860766e-32, INFINITY

    The generator **does not** generate negative zeros or negative infinities.
    It is possible to generate positive infinity and NaNs, but is highly
    unlikely.

.. c:function:: id<FOXGenerator> FOXFamousDouble(void)

    Generates random doubles that conform to the IEEE 754 standard in a boxed
    NSNumber. Shrinks towards zero by shrinking the double's exponent and
    mantissa. Unlike :c:func:`FOXDouble`, this generator increases the
    likelihood of generating extreme values (max of double, -(max of double),
    INFINITY, -INFINITY, -0, NaN)::  

        FOXFamousDouble()
        // example generations: 0, 6.983507489299851e-251, -INFINITY

    The generator **does not** generate negative zeros or negative infinities.
    It is possible to generate positive infinity and NaNs, but is highly
    unlikely.

.. c:function:: id<FOXGenerator> FOXDecimalNumber(void)

    Generates random decimal numbers. Shrinks towards zero by shrinking the
    mantissa and exponent.

    The generator **does not** generate NaNs::

        FOXDecimalNumber()
        // example generations: 0, -192000000000000000000000000000000000000000000, 790000000000000000000000000000000000000000000000000000000000000000000000000000

.. c:function:: id<FOXGenerator> FOXReturn(id value)

    Generates only the value provided. Does not shrink::

        FOXReturn(@2)
        // example generations: 2

.. c:function:: id<FOXGenerator> FOXTuple(NSArray *generators)

    Generates a fixed-size arrays where each element corresponds to each of the
    generators provided::

        FOXTuple(@[FOXInteger(), FOXDecimalNumber()]);
        // example generations: @[@0, @0], @[@2, @-129]

    Shrinking is the smallest value for each of the generators provided. The
    array does not change size.

.. c:function:: id<FOXGenerator> FOXTupleOfGenerators(id<FOXSequence> *generators)

    Identical to ``FOXTuple``, but accepts a FOXSequence of generators instead of
    an array::

        id<FOXSequence> generators = [FOXSequence sequenceFromArray:@[FOXInteger(), FOXDecimalNumber()]];
        FOXTupleOfGenerators(@[FOXInteger(), FOXDecimalNumber()]);
        // example generations: @[@0, @0], @[@2, @-129]

.. c:function:: id<FOXGenerator> FOXArray(id<FOXGenerator> itemGenerator)

    Generates a variable-sized array where each element is created via the
    itemGenerator. Shrinking reduces the size of the array as well as each
    element generated::

        FOXArrayOfSize(FOXInteger(), 3)
        // example generations: @[@0, @0, @0], @[@2, @-129, @21]

.. c:function:: id<FOXGenerator> FOXArrayOfSize(id<FOXGenerator> itemGenerator, NSUInteger size)

    Generates a fixed-size array where each element is created via the
    itemGenerator. Shrinking only reduces the size of each element generated::

        id<FOXSequence> generators = [FOXSequence sequenceFromArray:@[FOXInteger(), FOXDecimalNumber()]];
        FOXArrayOfSize(FOXInteger(), 3)
        // example generations: @[@0, @0, @0], @[@2, @-129, @21]

.. c:function:: id<FOXGenerator> FOXArrayOfSizeRange(id<FOXGenerator> itemGenerator, NSUInteger minSize, NSUInteger maxSize)

    Generates a variable-sized array where each element is created via the
    itemGenerator. The size of the array is within the specified range
    (inclusive). Shrinking reduces the size of the array to minSize as well as
    each element generated::

        id<FOXSequence> generators = [FOXSequence sequenceFromArray:@[FOXInteger(), FOXDecimalNumber()]];
        FOXArrayOfSizeRange(FOXInteger(), 1, 2)
        // example generations: @[@0], @[@2, @-129]

.. c:function:: id<FOXGenerator> FOXDictionary(NSDictionary *template)

    Generates random dictionaries of generated values. Keys are known values
    ahead of time. Specified in `@{<key>: <generator>}` form::

        FOXDictionary(@{@"name": FOXString(),
                        @"age": FOXInteger()});
        // example generations: @{@"name": @"", @"age": @0}

    Only values shrink. The number of pairs the dictionary holds does not
    shrink.

.. c:function:: id<FOXGenerator> FOXSet(id<FOXGenerator> generator)

    Generates random sets of generated values. The size of the set is not
    deterministic. Values generated should support the methods required to be
    placed in an NSSet. Shrinking is per element, which implicitly shrinks the
    set::

        FOXSet(FOXInteger())
        // example generations: [NSSet setWithObject:@1], [NSSet setWithObjects:@3, @2, nil]

.. c:function:: id<FOXGenerator> FOXCharacter(void)

    Generates random 1-length sized character string. It may be an unprintable
    character. Shrinks to smaller ascii numeric values::

        FOXCharacter()
        // example generations: @"\0", @"f", @"k"

.. c:function:: id<FOXGenerator> FOXAlphabeticalCharacter(void)

    Generates random 1-length sized alphabetical string. Includes both upper
    and lower case. Shrinks to smaller ascii numeric values::

        FOXAlphabeticalCharacter()
        // example generations: @"A", @"a", @"k"

.. c:function:: id<FOXGenerator> FOXNumericCharacter(void)

    Generates random 1-length sized numeric string (0-9). Shrinks to smaller
    ascii numeric values::

        FOXNumericCharacter()
        // example generations: @"0", @"1", @"9"

.. c:function:: id<FOXGenerator> FOXAlphanumericCharacter(void)

    Generates random 1-length sized numeric string (A-Z,a-z,0-9). Shrinks to
    smaller ascii numeric values::

        FOXAlphanumericCharacter()
        // example generations: @"A", @"d", @"7"

.. c:function:: id<FOXGenerator> FOXAsciiCharacter(void)

    Generates random 1-length sized character string. It is ensured to be
    printable. Shrinks to smaller ascii numeric values::

        FOXAsciiCharacter()
        // example generations: @"A", @"d", @"7", @"%"

.. c:function:: id<FOXGenerator> FOXString(void)

    Generates random variable length strings. It may be an unprintable string.
    Shrinks to smaller ascii numeric values and smaller length strings::

        FOXString()
        // example generations: @"", @"fo$#@52\n\0", @"sfa453"

.. c:function:: id<FOXGenerator> FOXStringOfLength(NSUInteger length)

    Generates random fixed-length strings. It may be an unprintable string.
    Shrinks to smaller ascii numeric values and smaller length strings::

        FOXStringOfLength(5)
        // example generations: @"fdg j", @"f#%2\0", @"23zzf"

.. c:function:: id<FOXGenerator> FOXStringOfLengthRange(NSUInteger minLength, NSUInteger maxLength)

    Generates random variable length strings within the given range
    (inclusive). It may be an unprintable string. Shrinks to smaller ascii
    numeric values and smaller length strings::

        FOXStringOfLengthRange(3, 5)
        // example generations: @"fgsj", @"b 2", @"65a\n\0"

.. c:function:: id<FOXGenerator> FOXAsciiString(void)

    Generates random variable length ascii-only strings.
    Shrinks to smaller ascii numeric values and smaller length strings::

        FOXAsciiString()
        // example generations: @"fgsj", @"b 2", @"65a"

.. c:function:: id<FOXGenerator> FOXAsciiStringOfLength(NSUInteger length)

    Generates random fixed-length ascii-only strings.  Shrinks to smaller ascii
    numeric values and smaller length strings::

        FOXAsciiStringOfLength(5)
        // example generations: @"fgsj1", @"b 122", @"65abb"

.. c:function:: id<FOXGenerator> FOXAsciiStringOfLengthRange(NSUInteger minLength, NSUInteger maxLength)

    Generates random variable length ascii-only strings within the given range
    (inclusive). Shrinks to smaller ascii numeric values and smaller length
    strings::

        FOXAsciiStringOfLengthRange(2, 5)
        // example generations: @"fg", @" 122", @"abb"

.. c:function:: id<FOXGenerator> FOXAlphabeticalString(void)

    Generates random variable length alphabetical strings. Includes upper and
    lower cased strings.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXAlphabeticalString()
        // example generations: @"fg", @"admm", @"oiuteoer"

.. c:function:: id<FOXGenerator> FOXAlphabeticalStringOfLength(NSUInteger length)

    Generates random fixed-length alphabetical strings. Includes upper and
    lower cased letters.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXAlphabeticalStringOfLength(4)
        // example generations: @"fguu", @"admm", @"ueer"

.. c:function:: id<FOXGenerator> FOXAlphabeticalStringOfLengthRange(NSUInteger minLength, NSUInteger maxLength)

    Generates random variable length alphabetical strings within the given
    range (inclusive). Includes upper and lower cased strings. Shrinks to
    smaller ascii numeric values and smaller length strings::

        FOXAlphabeticalStringOfLengthRange(2, 4)
        // example generations: @"fguu", @"adm", @"ee"

.. c:function:: id<FOXGenerator> FOXAlphanumericalString(void)

    Generates random variable length alphanumeric strings. Includes upper and
    lower cased strings.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXAlphanumericalString()
        // example generations: @"fg9u", @"a3M", @"fkljlkbd3241ee"

.. c:function:: id<FOXGenerator> FOXAlphanumericalStringOfLength(NSUInteger length)

    Generates random fixed-length alphanumeric strings. Includes upper and
    lower cased letters.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXAlphanumericalStringOfLength(3)
        // example generations: @"fg9", @"a3M", @"1ee"

.. c:function:: id<FOXGenerator> FOXAlphanumericalStringOfLengthRange(NSUInteger minLength, NSUInteger maxLength)

    Generates random variable length alphanumeric strings within the given
    range (inclusive). Includes upper and lower cased strings. Shrinks to
    smaller ascii numeric values and smaller length strings::

        FOXAlphanumericalStringOfLengthRange(2, 3)
        // example generations: @"fg9", @"aM", @"1e"

.. c:function:: id<FOXGenerator> FOXNumericalString(void)

    Generates random variable length numeric strings (0-9). Includes upper and
    lower cased strings.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXNumericalString()
        // example generations: @"", @"62", @"0913024"

.. c:function:: id<FOXGenerator> FOXNumericalStringOfLength(NSUInteger length)

    Generates random fixed-length numeric strings (0-9). Includes upper and
    lower cased letters.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXNumericalStringOfLength(3)
        // example generations: @"521", @"620", @"091"

.. c:function:: id<FOXGenerator> FOXNumericalStringOfLengthRange(NSUInteger minLength, NSUInteger maxLength)

    Generates random variable length numeric strings (0-9) within the given
    range (inclusive). Includes upper and lower cased strings. Shrinks to
    smaller ascii numeric values and smaller length strings::

        FOXNumericalStringOfLengthRange(2, 5)
        // example generations: @"21", @"620", @"05991"

.. c:function:: id<FOXGenerator> FOXElements(NSArray *values)

    Generates one of the specified values at random. Does not shrink::

        FOXElements(@[@1, @5, @9]);
        // example generations: @1, @5, @9

.. c:function:: id<FOXGenerator> FOXSimpleType(void)

    Generates random simple types. A simple type is a data type that is not
    made of other types. The value generated may not be safe to print to
    console. Shrinks according to the data type generated.

    Currently, the generators this uses are:

        - FOXInteger()
        - FOXDouble()
        - FOXString()
        - FOXBoolean()

    But this generator may change to cover more data types at any time.

.. c:function:: id<FOXGenerator> FOXPrintableSimpleType(void)

    Generates random simple types. A simple type is a data type that is not
    made of other types. The value generated is ensured to be printable to
    console. Shrinks according to the data type generated.

    Currently, the generators this uses are:

        - FOXInteger()
        - FOXDouble()
        - FOXAsciiString()
        - FOXBoolean()

    But this generator may change to cover more data types at any time.

.. c:function:: id<FOXGenerator> FOXCompositeType(id<FOXGenerator> itemGenerator)

    Generates random composite types. A composite type contains other data types.
    Elements of the composite type are from the provided itemGenerator..
    Shrinks according to the data type generated.

    Currently, the generators this uses are:

        - FOXArray()
        - FOXSet()

    But this generator may change to cover more data types at any time.

.. c:function:: id<FOXGenerator> FOXAnyObject(void)

    Generates random simple or composite types. Shrinking is dependent on the
    type generated.

    Currently the generators this uses are:

        - FOXSimpleType()
        - FOXCompositeType()

    But this generator may change to cover more data types at any time.

.. c:function:: id<FOXGenerator> FOXAnyPrintableObject(void)

    Generates random printable simple or composite types. Shrinking is
    dependent on the type generated.

    Currently the generators this uses are:

        - FOXPrintableSimpleType()
        - FOXCompositeType()

    But this generator may change to cover more data types at any time.

Combinators
-----------

Also, you can compose some computation work on top of data generators. The resulting
generator usually adopts the same shrinking properties as the original generator.

.. c:function:: id<FOXGenerator> FOXMap(id<FOXGenerator> generator, id(^fn)(id generatedValue))

    Applies a block to each generated value. Shrinking is dependent on the
    original generator::

        // create a generator that produces strictly positive integers.
        FOXMap(FOXInteger(), ^id(NSNumber *value) {
            return @(ABS([value integerValue]) ?: 1);
        });

.. c:function:: id<FOXGenerator> FOXBind(id<FOXGenerator> generator, id<FOXGenerator> (^fn)(id generatedValue))

    Applies a block to the value that the original generator generates. The
    block is expected to return a new generator. Shrinking is dependent on the
    original generator.  This is a way to create a new generator from the input
    of another generator's value::

        // create a generator that produces arrays of random capacities
        // Shinks as value does (towards zero).
        FOXBind(FOXPositiveInteger(), ^id<FOXGenerator>(NSNumber *value) {
            return FOXReturn([NSArray arrayWithCapacity:[value integerValue]]);
        });

.. c:function:: id<FOXGenerator> FOXResize(id<FOXGenerator> generator, NSUInteger newSize)

    Overrides the given generator's size parameter with the specified size::

        FOXResize(FOXArray(FOXInteger()), 10);

.. c:function:: id<FOXGenerator> FOXOptional(id<FOXGenerator> generator)

    Creates a new generator that has a 25% chance of returning `nil` instead of
    the provided generated value::

        // A 25% chance of returning nil instead of NSNumber
        FOXOptional(FOXInteger())
        // example generations: @1, @5, nil, @22

.. c:function:: id<FOXGenerator> FOXFrequency(NSArray *tuples)

    Dispatches to one of many generators by probability. Takes an array of
    tuples (2-sized array) - ``@[@[@probability_uint, generator]]``. Shrinking
    follows whatever generator is returned::

        // equivalent to FOXOptional(FOXInteger())
        FOXFrequency(@[@[@1, FOXReturn(nil)],
                       @[@3, FOXInteger()]]);
        // example generations: @1, @5, nil, @22

.. c:function:: id<FOXGenerator> FOXSized(id<FOXGenerator> (^fn)(NSUInteger size))

    Encloses the given block to create generator that is dependent on the size
    hint generators receive when generating values::

        // returns a generator that creates arrays with specific capacities.
        // the capacities grow as the size hint grows. A large size hint can
        // still generate smaller size values.
        //
        // No shrinking because we're using FOXReturn.
        FOXSized(^id<FOXGenerator>(NSUInteger size) {
            return FOXReturn([NSArray arrayWithCapacity:size]);
        });

.. c:function:: id<FOXGenerator> FOXSuchThat(id<FOXGenerator> generator, BOOL(^predicate)(id generatedValue))

    Returns each generated value if-and-only-if it satisfies the given block.
    If the filter excludes more than 10 values in a row, the resulting
    generator assumes it has reached maximum shrinking::

        // inefficiently generates only even numbers.
        FOXSuchThat(FOXInteger(), ^BOOL(NSNumber *value) {
            return [value integerValue] % 2 == 0;
        });

    .. warning:: Using ``FOXSuchThat`` and ``FOXSuchThatWithMaxTries`` are "filter"
                generators and can lead to significant waste in test generation by
                Fox. While it gives you the most flexibility the kind of generated
                data, it is the most computationally expensive. Use other
                generators when possible.

.. c:function:: id<FOXGenerator> FOXSuchThatWithMaxTries(id<FOXGenerator> generator, BOOL(^predicate)(id generatedValue), NSUInteger maxTries)

    Returns each generated value iff it satisfies the given block. If the
    filter excludes more than the given max tries in a row, the resulting
    generator assumes it has reached maximum shrinking::

        // inefficiently generates numbers divisible by 10.
        FOXSuchThat(FOXInteger(), ^BOOL(NSNumber *value) {
            return [value integerValue] % 10 == 0;
        });

    .. warning:: Using ``FOXSuchThat`` and ``FOXSuchThatWithMaxTries`` are "filter"
                generators and can lead to significant waste in test generation by
                Fox. While it gives you the most flexibility the kind of generated
                data, it is the most computationally expensive. Use other
                generators when possible.

.. c:function:: id<FOXGenerator> FOXOneOf(NSArray *generators)

    Returns generated values by randomly picking from an array of generators.
    Shrinking is dependent on the generator chosen::

        // evenly distributed between integers and strings
        FOXOneOf(@[FOXInteger(), FOXString()]);
        // example generations: @1, @"bgj%)#x", @9

.. c:function:: id<FOXGenerator> FOXForAll(id<FOXGenerator> generator, BOOL (^then)(id generatedValue))

    Asserts using the block and a generator and produces test assertion results
    (FOXPropertyResult). FOXPropertyResult is a data structure storing the
    results of the assertion. Shrinking tests against smaller values of the
    given generator::

        FOXForAll(FOXInteger(), ^BOOL(NSNumber *generatedValue) {
            // will fail eventually
            return [generatedValue integerValue] > 0;
        });
        // example generations: <FOXPropertyResult: pass>, <FOXPropertyResult: fail>

.. c:function:: id<FOXGenerator> FOXForSome(id<FOXGenerator> generator, FOXPropertyStatus (^then)(id generatedValue))

    Like FOXForAll, but allows the assertion block to "skip" potentially
    invalid test cases::

        FOXForAll(FOXInteger(), ^BOOL(NSNumber *generatedValue) {
            // skip tests if 0 was generated
            if ([generatedValue integerValue] == 0) {
                return FOXPropertyStatusSkipped;
            }
            // will fail eventually
            return [generatedValue integerValue] > 0;
        });
        // example generations: <FOXPropertyResult: pass>, <FOXPropertyResult: fail>, <FOXPropertyResult: skipped> 

.. c:function:: id<FOXGenerator> FOXCommands(id<FOXStateMachine> stateMachine)

    Generates arrays of FOXExecuteCommands that satisfies a given state
    machine. Can be passed to FOXExecutedSuccessfully to verify if the subject
    conforms to the state machine.

    .. note:: It's recommended to use FOXSerialProgram instead. FOXCommands
            may be deprecated and removed at a later date.

.. c:function:: id<FOXGenerator> FOXExecuteCommands(id<FOXStateMachine> stateMachine)

    Generates arrays of FOXExecutedCommands that satisfies a given state
    machine and executed against a subject. Can be passed to
    FOXExecutedSuccessfully to verify if the subject conforms to the state
    machine.

    .. note:: It's recommended to use FOXRunSerialProgram instead.
            FOXExecuteCommands may be deprecated and removed at a later date.

.. c:function:: id<FOXGenerator> FOXSerialProgram(id<FOXStateMachine> stateMachine)

    **Currently ALPHA - subject to change at any point**

    Generates a FOXProgram that conforms to a given state machine. A program is
    an abstract representation of a series of API calls (FOXCommands) to invoke.

    Use :c:func:`FOXRunSerialProgram` to executed a FOXProgram and
    :c:func:`FOXReturnOrRaisePrettyProgram` to verify the executed program::

        FORForAll(FOXSerialProgram(stateMachine), ^BOOL(FOXProgram *program) {
            Queue *subject = [Queue new];
            FOXExecutedProgram *executedProgram = FOXRunSerialProgram(program, subject);
            return FOXReturnOrRaisePrettyProgram(executedProgram);
        });

    Shrinking removes irrelevant commands to provoke the failure. Do not
    intermix serial commands with parallel commands.

.. c:function:: id<FOXGenerator> FOXParallelProgram(id<FOXStateMachine> stateMachine)

    **Currently ALPHA - subject to change at any point**

    Generates a FOXProgram that conforms to a given state machine. A program is
    an abstract representation of a series of parallel API calls (FOXCommands)
    to invoke. Each state transition for the state machine should be atomic.

    This verifies `linearizability`_ of the subject under test.

    Use :c:func:`FOXRunParallelProgram` to executed the FOXProgram on multiple threads
    and :c:func:`FOXReturnOrRaisePrettyProgram` to verify the executed program::

        // Warning: Shrinking is non-deterministic due to its parallel nature.
        FORForAll(FOXParallelProgram(stateMachine), ^BOOL(FOXProgram *program) {
            FOXExecutedProgram *executedProgram = FOXRunParallelProgram(program, ^id {
                return [Queue new];
            });
            return FOXReturnOrRaisePrettyProgram(executedProgram);
        });

    Shrinking removes irrelevant commands to provoke the failure. Do not
    intermix serial commands with parallel commands.

    .. warning:: Due to the non-deterministic nature of parallel code, Fox cannot
                reliably shrink a failing example to the smallest counter example
                when only using FOXParallelProgram().

    FOXScheduler and Foxling can help serialize thread execution to be more
    deterministic::

        // Warning: this code should be compiled with the Foxling compiler
        id<FOXGenerator> programs = FOXTuple(@[FOXParallelProgram(stateMachine),
                                               FOXSeed()]);
        FORForAll(programs, ^BOOL(NSArray *tuple) {
            FOXProgram *program = tuple[0];
            id<FOXRandom> prng = tuple[1];

            FOXScheduler *scheduler = [[FOXScheduler alloc] initWithRandom:prng];
            __block FOXExecutedProgram *executedProgram = nil;
            [executedProgram runAndWait:^{
                executedProgram = FOXRunParallelProgram(program, ^id {
                    return [Queue new];
                });
            }];
            return FOXReturnOrRaisePrettyProgram(executedProgram);
        });

    Read more about :doc:`parallel testing <parallel/tutorial>` for limitations
    and quirks.

.. _linearizability: http://en.wikipedia.org/wiki/Linearizability

Helper Functions
----------------

Helper functions used in conjunction with existing generators.

.. c:function:: FOXExecutedProgram *FOXRunSerialProgram(FOXProgram *program, id subject)

    **Currently ALPHA - subject to change at any point**

    Executes a given serial program and records its results in the returned
    FOXExecutedProgram.

    Use `FOXReturnOrRaisePrettyProgram`:c:func: to verify the executed program.

.. c:function:: FOXExecutedProgram *FOXRunParallelProgram(FOXProgram *program, id(^subjectFactory)())

    **Currently ALPHA - subject to change at any point**

    Executes a given parallel program and records its results in the returned
    FOXExecutedProgram. The block argument produces a new instance of the
    subject under test.

    Use `FOXReturnOrRaisePrettyProgram`:c:func: to verify the executed program.

.. c:function:: BOOL FOXReturnOrRaisePrettyProgram(FOXExecutedProgram *program)

    **Currently ALPHA - subject to change at any point**

    Verifies the executed program and returns ``YES`` if the program executed
    in line with the state machine. Raises a control-flow exception to pass
    executed program results to assist in printing return values when executing
    commands.

    .. note:: While raising exceptions are not ideal for an API, this may change when a major
              API refactor occurs (2.x.x).

.. _Debugging Functions:

Debugging Functions
-------------------

Fox comes with a handful of functions that can help you diagnose generator problems.

.. c:function:: NSArray *FOXSample(id<FOXGenerator> generator)

    Samples 10 values that generator produces.

.. c:function:: NSArray *FOXSampleWithCount(id<FOXGenerator> generator, NSUInteger numberOfSamples)

    Samples a number of values that a generator produces.

.. c:function:: NSArray *FOXSampleShrinking(id<FOXGenerator> generator)

    Samples 10 steps of shrinking from a value that a generator produces.

.. c:function:: NSArray *FOXSampleShrinkingWithCount(id<FOXGenerator> generator, NSUInteger numberOfSamples)

    Samples a number of steps of shrinking from a value that a generator
    produces.


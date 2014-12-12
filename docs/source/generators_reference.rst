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

.. c:function:: id<FOXGenerator> FOXInteger(void) // NSNumber

    Generates random integers boxed as a NSNumber. Shrinks to 0::

        FOXInteger()
        // example generations: 0, -1, 1

.. c:function:: id<FOXGenerator> FOXPositiveInteger(void) // NSNumber

    Generates random positive integers boxed as a NSNumber. Shrinks to 0::

        FOXPositiveInteger()
        // example generations: 0, 1, 2

.. c:function:: id<FOXGenerator> FOXNegativeInteger(void) // NSNumber

    Generates random negative integers boxed as a NSNumber. Shrinks to 0::

        FOXNegativeInteger()
        // example generations: 0, -1, -2

.. c:function:: id<FOXGenerator> FOXStrictPositiveInteger(void) // NSNumber

    Generates random positive integers boxed as a NSNumber. Shrinks to 1::

        FOXStrictPositiveInteger()
        // example generations: 1, 2, 3

.. c:function:: id<FOXGenerator> FOXStrictNegativeInteger(void) // NSNumber

    Generates random negative integers boxed as a NSNumber. Shrinks to -1::

        FOXStrictNegativeInteger()
        // example generations: -1, -2, -3

.. c:function:: id<FOXGenerator> FOXChoose(NSNumber *miniumNumber, NSNumber *maximumNumber) // NSNumber

    Generates random integers boxed as a NSNumber within the given range
    (inclusive). Shrinks to miniumNumber. The miniumNumber can never be greater
    than maximumNumber::

        FOXChoose(@5, @10)
        // example generations: 5, 6, 7

.. c:function:: id<FOXGenerator> FOXFloat(void) // NSNumber

    Generates random floating point numbers that conform to the IEEE 754
    standard in a boxed NSNumber. Shrinks towards zero by shrinking the float's
    exponent and mantissa::

        FOXFloat()
        // example generations: 0, 3.436027e+10, -9.860766e-32

    The generator **does not** generate negative zeros or negative infinities.
    It is possible to generate positive infinity and NaNs, but is highly
    unlikely.

.. c:function:: id<FOXGenerator> FOXDouble(void) // NSNumber

    Generates random doubles that conform to the IEEE 754 standard in a boxed
    NSNumber. Shrinks towards zero by shrinking the double's exponent and
    mantissa::

        FOXDouble()
        // example generations: 0, 6.983507489299851e-251, -3.101300322905138e-266

    The generator **does not** generate negative zeros or negative infinities.
    It is possible to generate positive infinity and NaNs, but is highly
    unlikely.

.. c:function:: id<FOXGenerator> FOXDecimalNumber(void) // NSDecimalNumber

    Generates random decimal numbers. Shrinks towards zero by shrinking the
    mantissa and exponent.

    The generator **does not** generate NaNs::

        FOXDecimalNumber()
        // example generations: 0, -192000000000000000000000000000000000000000000, 790000000000000000000000000000000000000000000000000000000000000000000000000000

.. c:function:: id<FOXGenerator> FOXReturn(id value) // id

    Generates only the value provided. Does not shrink::

        FOXReturn(@2)
        // example generations: 2

.. c:function:: id<FOXGenerator> FOXTuple(NSArray *generators) // NSArray

    Generates a fixed-size arrays where each element corresponds to each of the
    generators provided::

        FOXTuple(@[FOXInteger(), FOXDecimalNumber()]);
        // example generations: @[@0, @0], @[@2, @-129]

    Shrinking is the smallest value for each of the generators provided. The
    array does not change size.

.. c:function:: id<FOXGenerator> FOXTupleOfGenerators(id<FOXSequence> *generators) // NSArray

    Identical to ``FOXTuple``, but accepts a FOXSequence of generators instead of
    an array::

        id<FOXSequence> generators = [FOXSequence sequenceFromArray:@[FOXInteger(), FOXDecimalNumber()]];
        FOXTupleOfGenerators(@[FOXInteger(), FOXDecimalNumber()]);
        // example generations: @[@0, @0], @[@2, @-129]

.. c:function:: id<FOXGenerator> FOXArray(id<FOXGenerator> itemGenerator) // NSArray

    Generates a variable-sized array where each element is created via the
    itemGenerator. Shrinking reduces the size of the array as well as each
    element generated::

        FOXArrayOfSize(FOXInteger(), 3)
        // example generations: @[@0, @0, @0], @[@2, @-129, @21]

.. c:function:: id<FOXGenerator> FOXArrayOfSize(id<FOXGenerator> itemGenerator, NSUInteger size) // NSArray

    Generates a fixed-size array where each element is created via the
    itemGenerator. Shrinking only reduces the size of each element generated::

        id<FOXSequence> generators = [FOXSequence sequenceFromArray:@[FOXInteger(), FOXDecimalNumber()]];
        FOXArrayOfSize(FOXInteger(), 3)
        // example generations: @[@0, @0, @0], @[@2, @-129, @21]

.. c:function:: id<FOXGenerator> FOXArrayOfSizeRange(id<FOXGenerator> itemGenerator, NSUInteger minSize, NSUInteger maxSize) // NSArray

    Generates a variable-sized array where each element is created via the
    itemGenerator. The size of the array is within the specified range
    (inclusive). Shrinking reduces the size of the array to minSize as well as
    each element generated::

        id<FOXSequence> generators = [FOXSequence sequenceFromArray:@[FOXInteger(), FOXDecimalNumber()]];
        FOXArrayOfSizeRange(FOXInteger(), 1, 2)
        // example generations: @[@0], @[@2, @-129]

.. c:function:: id<FOXGenerator> FOXDictionary(NSDictionary *template) // NSDictionary

    Generates random dictionaries of generated values. Keys are known values
    ahead of time. Specified in `@{<key>: <generator>}` form::

        FOXDictionary(@{@"name": FOXString(),
                        @"age": FOXInteger()});
        // example generations: @{@"name": @"", @"age": @0}

    Only values shrink. The number of pairs the dictionary holds does not
    shrink.

.. c:function:: id<FOXGenerator> FOXSet(id<FOXGenerator> generator) // NSSet

    Generates random sets of generated values. The size of the set is not
    deterministic. Values generated should support the methods required to be
    placed in an NSSet. Shrinking is per element, which implicitly shrinks the
    set::

        FOXSet(FOXInteger())
        // example generations: [NSSet setWithObject:@1], [NSSet setWithObjects:@3, @2, nil]

.. c:function:: id<FOXGenerator> FOXCharacter(void) // NSString

    Generates random 1-length sized character string. It may be an unprintable
    character. Shrinks to smaller ascii numeric values::

        FOXCharacter()
        // example generations: @"\0", @"f", @"k"

.. c:function:: id<FOXGenerator> FOXAlphabeticalCharacter(void) // NSString

    Generates random 1-length sized alphabetical string. Includes both upper
    and lower case. Shrinks to smaller ascii numeric values::

        FOXAlphabeticalCharacter()
        // example generations: @"A", @"a", @"k"

.. c:function:: id<FOXGenerator> FOXNumericCharacter(void) // NSString

    Generates random 1-length sized numeric string (0-9). Shrinks to smaller
    ascii numeric values::

        FOXNumericCharacter()
        // example generations: @"0", @"1", @"9"

.. c:function:: id<FOXGenerator> FOXAlphanumericCharacter(void) // NSString

    Generates random 1-length sized numeric string (A-Z,a-z,0-9). Shrinks to
    smaller ascii numeric values::

        FOXAlphanumericCharacter()
        // example generations: @"A", @"d", @"7"

.. c:function:: id<FOXGenerator> FOXAsciiCharacter(void) // NSString

    Generates random 1-length sized character string. It is ensured to be
    printable. Shrinks to smaller ascii numeric values::

        FOXAsciiCharacter()
        // example generations: @"A", @"d", @"7", @"%"

.. c:function:: id<FOXGenerator> FOXString(void) // NSString

    Generates random variable length strings. It may be an unprintable string.
    Shrinks to smaller ascii numeric values and smaller length strings::

        FOXString()
        // example generations: @"", @"fo$#@52\n\0", @"sfa453"

.. c:function:: id<FOXGenerator> FOXStringOfLength(NSUInteger length) // NSString

    Generates random fixed-length strings. It may be an unprintable string.
    Shrinks to smaller ascii numeric values and smaller length strings::

        FOXStringOfLength(5)
        // example generations: @"fdg j", @"f#%2\0", @"23zzf"

.. c:function:: id<FOXGenerator> FOXStringOfLengthRange(NSUInteger minLength, NSUInteger maxLength) // NSString

    Generates random variable length strings within the given range
    (inclusive). It may be an unprintable string. Shrinks to smaller ascii
    numeric values and smaller length strings::

        FOXStringOfLengthRange(3, 5)
        // example generations: @"fgsj", @"b 2", @"65a\n\0"

.. c:function:: id<FOXGenerator> FOXAsciiString(void) // NSString

    Generates random variable length ascii-only strings.
    Shrinks to smaller ascii numeric values and smaller length strings::

        FOXAsciiString()
        // example generations: @"fgsj", @"b 2", @"65a"

.. c:function:: id<FOXGenerator> FOXAsciiStringOfLength(NSUInteger length) // NSString

    Generates random fixed-length ascii-only strings.  Shrinks to smaller ascii
    numeric values and smaller length strings::

        FOXAsciiStringOfLength(5)
        // example generations: @"fgsj1", @"b 122", @"65abb"

.. c:function:: id<FOXGenerator> FOXAsciiStringOfLengthRange(NSUInteger minLength, NSUInteger maxLength) // NSString

    Generates random variable length ascii-only strings within the given range
    (inclusive). Shrinks to smaller ascii numeric values and smaller length
    strings::

        FOXAsciiStringOfLengthRange(2, 5)
        // example generations: @"fg", @" 122", @"abb"

.. c:function:: id<FOXGenerator> FOXAlphabeticalString(void) // NSString

    Generates random variable length alphabetical strings. Includes upper and
    lower cased strings.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXAlphabeticalString()
        // example generations: @"fg", @"admm", @"oiuteoer"

.. c:function:: id<FOXGenerator> FOXAlphabeticalStringOfLength(NSUInteger length) // NSString

    Generates random fixed-length alphabetical strings. Includes upper and
    lower cased letters.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXAlphabeticalStringOfLength(4)
        // example generations: @"fguu", @"admm", @"ueer"

.. c:function:: id<FOXGenerator> FOXAlphabeticalStringOfLengthRange(NSUInteger minLength, NSUInteger maxLength) // NSString

    Generates random variable length alphabetical strings within the given
    range (inclusive). Includes upper and lower cased strings. Shrinks to
    smaller ascii numeric values and smaller length strings::

        FOXAlphabeticalStringOfLengthRange(2, 4)
        // example generations: @"fguu", @"adm", @"ee"

.. c:function:: id<FOXGenerator> FOXAlphanumericalString(void) // NSString

    Generates random variable length alphanumeric strings. Includes upper and
    lower cased strings.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXAlphanumericalString()
        // example generations: @"fg9u", @"a3M", @"fkljlkbd3241ee"

.. c:function:: id<FOXGenerator> FOXAlphanumericalStringOfLength(NSUInteger length) // NSString

    Generates random fixed-length alphanumeric strings. Includes upper and
    lower cased letters.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXAlphanumericalStringOfLength(3)
        // example generations: @"fg9", @"a3M", @"1ee"

.. c:function:: id<FOXGenerator> FOXAlphanumericalStringOfLengthRange(NSUInteger minLength, NSUInteger maxLength) // NSString

    Generates random variable length alphanumeric strings within the given
    range (inclusive). Includes upper and lower cased strings. Shrinks to
    smaller ascii numeric values and smaller length strings::

        FOXAlphanumericalStringOfLengthRange(2, 3)
        // example generations: @"fg9", @"aM", @"1e"

.. c:function:: id<FOXGenerator> FOXNumericalString(void) // NSString

    Generates random variable length numeric strings (0-9). Includes upper and
    lower cased strings.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXNumericalString()
        // example generations: @"", @"62", @"0913024"

.. c:function:: id<FOXGenerator> FOXNumericalStringOfLength(NSUInteger length) // NSString

    Generates random fixed-length numeric strings (0-9). Includes upper and
    lower cased letters.  Shrinks to smaller ascii numeric values and smaller
    length strings::

        FOXNumericalStringOfLength(3)
        // example generations: @"521", @"620", @"091"

.. c:function:: id<FOXGenerator> FOXNumericalStringOfLengthRange(NSUInteger minLength, NSUInteger maxLength) // NSString

    Generates random variable length numeric strings (0-9) within the given
    range (inclusive). Includes upper and lower cased strings. Shrinks to
    smaller ascii numeric values and smaller length strings::

        FOXNumericalStringOfLengthRange(2, 5)
        // example generations: @"21", @"620", @"05991"

.. c:function:: id<FOXGenerator> FOXElements(NSArray *values)

    Generates one of the specified values at random. Does not shrink::

        FOXElements(@[@1, @5, @9]);
        // example generations: @1, @5, @9

.. c:function:: id<FOXGenerator> FOXSimpleType(void) // id

    Generates random simple types. A simple type is a data type that is not
    made of other types. The value generated may not be safe to print to
    console. Shrinks according to the data type generated.

    Currently, the generators this uses are:

        - FOXInteger()
        - FOXDouble()
        - FOXString()
        - FOXBoolean()

    But this generator may change to cover more data types at any time.

.. c:function:: id<FOXGenerator> FOXPrintableSimpleType(void) // id

    Generates random simple types. A simple type is a data type that is not
    made of other types. The value generated is ensured to be printable to
    console. Shrinks according to the data type generated.

    Currently, the generators this uses are:

        - FOXInteger()
        - FOXDouble()
        - FOXAsciiString()
        - FOXBoolean()

    But this generator may change to cover more data types at any time.

.. c:function:: id<FOXGenerator> FOXCompositeType(id<FOXGenerator> itemGenerator) // id

    Generates random composite types. A composite type contains other data types.
    Elements of the composite type are from the provided itemGenerator..
    Shrinks according to the data type generated.

    Currently, the generators this uses are:

        - FOXArray()
        - FOXSet()

    But this generator may change to cover more data types at any time.

.. c:function:: id<FOXGenerator> FOXAnyObject(void) // id

    Generates random simple or composite types. Shrinking is dependent on the
    type generated.

    Currently the generators this uses are:

        - FOXSimpleType()
        - FOXCompositeType()

    But this generator may change to cover more data types at any time.

.. c:function:: id<FOXGenerator> FOXAnyPrintableObject(void) // id

    Generates random printable simple or composite types. Shrinking is
    dependent on the type generated.

    Currently the generators this uses are:

        - FOXPrintableSimpleType()
        - FOXCompositeType()

    But this generator may change to cover more data types at any time.

Computation Generators
----------------------

Also, you can compose some computation work on top of data generators. The resulting
generator adopts the same shrinking properties as the original generator.

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
    returned generator.  This is a way to create a new generator from the input
    of another generator's value::

        // create a generator that produces arrays of random capacities
        // does not shrink because of FOXReturn's generator behavior.
        FOXBind(FOXPositiveInteger(), ^id<FOXGenerator>(NSNumber *value) {
            return FOXReturn([NSArray arrayWithCapacity:[value integerValue]]);
        });

.. c:function:: id<FOXGenerator> FOXResize(id<FOXGenerator> generator, NSUInteger newSize)

    Overrides the given generator's size parameter with the specified size.
    Prevents shrinking::

        // Similar to FOXArrayOfSizeRange(FOXInteger(), @0, @10)
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
    follows whatever generator is returned.

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

.. c:function:: id<FOXGenerator> FOXCommands(id<FFOXStateMachine> stateMachine)

    Generates arrays of FOXCommands that satisfies a given state machine.

.. c:function:: id<FOXGenerator> FOXExecuteCommands(id<FOXStateMachine> stateMachine)

    Generates arrays of FOXExecutedCommands that satisfies a given state
    machine and executed against a subject. Can be passed to
    FOXExecutedSuccessfully to verify if the subject conforms to the state
    machine.

.. _Debugging Functions:

Debugging Functions
-------------------

Fox comes with a handful of functions that can help you diagnose generator problems.

.. c:function:: id<FOXGenerator> FOXSample(id<FOXGenerator> generator)

    Samples 10 values that generator produces.

.. c:function:: id<FOXGenerator> FOXSampleWithCount(id<FOXGenerator> generator, NSUInteger numberOfSamples)

    Samples a number of values that a generator produces.

.. c:function:: id<FOXGenerator> FOXSampleShrinking(id<FOXGenerator> generator)

    Samples 10 steps of shrinking from a value that a generator produces.

.. c:function:: id<FOXGenerator> FOXSampleShrinkingWithCount(id<FOXGenerator> generator, NSUInteger numberOfSamples)

    Samples a number of steps of shrinking from a value that a generator
    produces.


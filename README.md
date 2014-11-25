Property Based Testing
======================

Property Based Testing for Objective-C. Automatic generation of software tests.

You might have heard of this or similar technologies through the various genres
of testing frameworks and/or libraries:

 - [Haskell QuickCheck](http://www.haskell.org/haskellwiki/Introduction_to_QuickCheck1)
 - [test.check](https://github.com/clojure/test.check)
 - Significantly more advanced [Erlang QuickCheck](http://www.quviq.com)
 - Property Based Testing
 - Model Based Testing

PBT is a port of test.check for Objective-C. Unlike some ports of QuickCheck,
PBT does implement shrinking (test.check does implement that too).

More thorough than Example-Based Tests
======================================

Test generation can provide a better coverage than example-based tests. Instead
of having to manually code test cases, PBT can generate tests for you.

Data Generation
---------------

The simpliest of test generation is providing random data.  PBT can generate
them for use if you can define specifications -- known properties of the
subject under test:

```objc
PBTRunner *runner = [[PBTRunner alloc] init];
// reads: for all integers x, y: x + y > x
PBTRunnerResult *result = [runner checkWithNumberOfTests:100
                                                    forAll:PBTTuple(PBTInteger(), PBTInteger())
                                                    then:^PBTPropertyResult(NSArray *tuple) {
    NSInteger x = [tuple[0] integerValue];
    NSInteger y = [tuple[1] integerValue];
    // PBTRequire converts bool into the PBTPropertyResult enum for passing or failing
    return PBTRequire(x + y > x);
}];

// verify
result.succeeded // => NO; failed
result.failingValue // => @[-9, @0]; random values generated
```

Once a failing example is produced, PBT will attempt to find the smallest
possible example that also exhibits the same failure:

```objc
result.smallestFailingValue // @[@0, @0]; the smallest example that fails
```

A short-hand way to verify this using the `PBTAssert` macro:

```objc
PBTAssert(PBTForAll(PBTTuple(PBTInteger(), PBTInteger()), ^BOOL(NSArray *values){
    NSInteger x = [tuple[0] integerValue];
    NSInteger y = [tuple[1] integerValue];
    return x + y > x;
});
```

Stateful Testing
----------------

How can you test stateful APIs? Represent the state changes as data! Using a
state machine, define a model of how your API is suppose to work. Here's one
for a queue:

```objc
// define a state machine. Model state is the state of your application and
// can be represented with any object you want -- PBT does not interpret it.
PBTFiniteStateMachine *stateMachine = [[PBTFiniteStateMachine alloc] initWithInitialModelState:@[]];

// Adds a transition to the state machine:
// - The API to test is -[addObject:]
// - The generator for the argument is a random integer in an NSNumber
// - A block indicating how to update the model state. This should not mutate the original model state.
[stateMachine addTransition:[PBTTransition byCallingSelector:@selector(addObject:)
                                               withGenerator:PBTInteger()
                                              nextModelState:^id(NSArray *modelState, id generatedValue) {
    return [modelState arrayByAddingObject:generatedValue];
}]];
// Add a custom transition (see PBTStateTransition protocol)
[stateMachine addTransition:[[QueueRemoveTransition alloc] init]];
```

Now, you can generate tests that exercise an API:

```objc
// Generate a sequence of commands executed on the given subject. Since
// this will generate multiple tests, you also give a block of a subject.
id<PBTGenerator> executedCommands = PBTExecuteCommands(stateMachine, ^id {
    return [PBTQueue new];
});

// Verify if the executed commands validated the API conformed to the state machine.
PBTRunnerResult *result = [PBTSpecHelper resultForAll:executedCommands
                                                 then:^BOOL(NSArray *commands) {
    return PBTExecutedSuccessfully(commands);
}];
// result will shrinking to the small sequence of API calls to trigger the
// failure if there is one
```

Reference
=========

Data Generators
---------------

There are many data generators provided for generating data. Most of these
generators shrink to zero:

 - Numerically zero (or as close as possible)
 - Empty collection (or at least shrunk items)

Function                  | Generates      | Description
------------------------- | --------------:| ------------
PBTInteger                | NSNumber *     | Generates random integers
PBTPositiveInteger        | NSNumber *     | Generates random zero or positive integers
PBTNegativeInteger        | NSNumber *     | Generates random zero or negative integers
PBTStrictPositiveInteger  | NSNumber *     | Generates random positive integers (non-zero)
PBTStrictNegativeInteger  | NSNumber *     | Generates random negative integers (non-zero)
PBTChoose                 | NSNumber *     | Generates random integers between the given range (inclusive)
PBTReturn                 | id             | Always returns the given value. Does not shrink
PBTTuple                  | NSArray *      | Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
PBTTupleOfGenerators      | NSArray *      | Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
PBTArray                  | NSArray *      | Generates random variable-sized arrays of generated values.
PBTArrayOfSize            | NSArray *      | Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
PBTArrayOfSizeRange       | NSArray *      | Generates random variable-sized arrays of generated values. Array size is within the given range (inclusive).
PBTDictionary             | NSDictionary * | Generates random dictionries of generated values. Keys are known values ahead of time. Specified in `@{<key>: <generator>}` form.
PBTSet                    | NSSet *        | Generates random sets of a given generated values.
PBTCharacter              | NSString *     | Generates random 1-length sized character string. May be an unprintable character.
PBTAlphabetCharacter      | NSString *     | Generates random 1-length sized character string. Only generates alphabetical letters.
PBTNumericCharacter       | NSString *     | Generates random 1-length sized character string. Only generates digits.
PBTAlphanumericCharacter  | NSString *     | Generates random 1-length sized character string. Only generates alphanumeric.
PBTAsciiCharacter         | NSString *     | Generates random 1-length sized character string. Only generates ascii characters.
PBTString                 | NSString *     | Generates random variable length strings. May be an unprintable string.
PBTAsciiString            | NSString *     | Generates random variable length strings. Only generates ascii characters.
PBTSimpleType             | id             | Generates random simple types. A simple type does not compose with other types. May not be printable.
PBTPrintableSimpleType    | id             | Generates random simple types. A simple type does not compose with other types. Ensured to be printable.
PBTCompositeType          | id             | Generates random composite types. A composite type composes with the given generator.

Computation Generators
----------------------

Also, you can compose some computation work on top of data generators. The resulting
generator adopts the same shrinking properties as the original generator.

Function                  | Description
------------------------- | ------------
PBTMap                    | Applies a block to each generated value.
PBTBind                   | Applies a block to the lazy tree that the original generator creates. See Building Generators section for more information.
PBTSized                  | Encloses the given block to create generator that is dependent on the size hint generators receive when generating values.
PBTSuchThat               | Returns each generated value iff it satisfies the given block. If the filter excludes more than 10 values in a row, the resulting generator assumes it has reached maximum shrinking.
PBTSuchThatWithMaxTries   | Returns each generated value iff it satisfies the given block. If the filter excludes more than the given max tries in a row, the resulting generator assumes it has reached maximum shrinking. 
PBTOneOf                  | Returns generated values by randomly picking from an array of generators. Shrinking will move towards the lower-indexed generators in the array.
PBTForAll                 | Asserts using the block and a generator and produces test assertion results (PBTPropertyResult). Shrinking tests against smaller values of the given generator.
PBTForSome                | Like PBTForAll, but allows the assertion block to "skip" potentially invalid test cases.
PBTCommands               | Generates arrays of PBTCommands that satisfies a given state machine.
PBTExecuteCommands        | Generates arrays of PBTExecutedCommands that satisfies a given state machine and executed against a subject. Can be passed to PBTExecutedSuccessfully to verify if the subject conforms to the state machine.



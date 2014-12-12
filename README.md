Fox
===

[![Build Status](https://travis-ci.org/jeffh/Fox.svg?branch=master)](https://travis-ci.org/jeffh/Fox)
[![Latest Documentation Status](https://readthedocs.org/projects/fox-testing/badge/?version=latest)](http://fox-testing.readthedocs.org/en/latest/)
[![v1.0.1 Documentation Status](https://readthedocs.org/projects/fox-testing/badge/?version=v1.0.0)](http://fox-testing.readthedocs.org/en/v1.0.1/)

Property Based Testing for Objective-C and Swift. Automatic generation of
software tests.

You might have heard of this or similar technologies through the various genres
of testing frameworks and/or libraries:

 - [Haskell QuickCheck](https://www.haskell.org/haskellwiki/Introduction_to_QuickCheck2)
 - [Clojure test.check](https://github.com/clojure/test.check)
 - [Erlang QuickCheck](http://www.quviq.com) (most advanced but commerical)
 - Property Based Testing
 - Model Based Testing
 - Simulation Testing

Fox is a port of test.check for Objective-C. Unlike some ports of QuickCheck,
Fox does implement shrinking (test.check does implement that too).

More thorough than Example-Based Tests
======================================

Test generation can provide better coverage than example-based tests. Instead
of having to manually code test cases, Fox can generate tests for you.

Data Generation
---------------

The simpliest of test generation is providing random data.  Fox can generate
them for use if you can define specifications -- known properties of the
subject under test:

```objc
FOXAssert(FOXForAll(FOXTuple(FOXInteger(), FOXInteger()), ^BOOL(NSArray *values){
    NSInteger x = [tuple[0] integerValue];
    NSInteger y = [tuple[1] integerValue];
    return x + y > x;
});
```

Once a failing example is produced, Fox will attempt to find the smallest
possible example that also exhibits the same failure:

    Property failed with: @[@0, @0].

Stateful Testing
----------------

How can you test stateful APIs? Represent the state changes as data! Using a
state machine, define a model of how your API is suppose to work. Here's one
for a queue:

```objc
// define a state machine. Model state is the state of your application and
// can be represented with any object you want -- Fox does not interpret it.
FOXFiniteStateMachine *stateMachine = [[FOXFiniteStateMachine alloc] initWithInitialModelState:@[]];

// Adds a transition to the state machine:
// - The API to test is -[addObject:]
// - The generator for the argument is a random integer in an NSNumber
// - A block indicating how to update the model state. This should not mutate the original model state.
[stateMachine addTransition:[FOXTransition byCallingSelector:@selector(addObject:)
                                               withGenerator:FOXInteger()
                                              nextModelState:^id(NSArray *modelState, id generatedValue) {
    return [modelState arrayByAddingObject:generatedValue];
}]];
// Add a custom transition (see FOXStateTransition protocol)
[stateMachine addTransition:[[QueueRemoveTransition alloc] init]];
```

Now, you can generate tests that exercise an API:

```objc
// Generate a sequence of commands executed on the given subject. Since
// this will generate multiple tests, you also give a block of a subject.
id<FOXGenerator> executedCommands = FOXExecuteCommands(stateMachine, ^id {
    return [FOXQueue new];
});

// Verify if the executed commands validated the API conformed to the state machine.
FOXRunnerResult *result = [FOXSpecHelper resultForAll:executedCommands
                                                 then:^BOOL(NSArray *commands) {
    return FOXExecutedSuccessfully(commands);
}];
// result will shrinking to the small sequence of API calls to trigger the
// failure if there is one
```

Read more at the [latest
documentation](http://fox-testing.readthedocs.org/en/latest/), or the [stable
documentation](http://fox-testing.readthedocs.org/en/v1.0.0/).

Installation
============

*From the [documentation](http://fox-testing.readthedocs.org/en/latest/).*

Fox can be installed in multiple ways. If you don't have a preference, install
via git submodule.

Fox honors [semantic versioning](http://semver.org) as humanly possible. If
you're unsure if a given update is backwards incompatible with your usage.
Check out the [releases](https://github.com/jeffh/Fox/releases).

Manually (Git Submodule)
------------------------

Add Fox as a submodule to your project:

    $ git submodule add https://github.com/jeffh/Fox.git Externals/Fox

If you don't want bleeding edge, check out the particular tag of the version:

    $ cd Externals/Fox
    $ git checkout v1.0.1

Add `Fox.xcodeproj` to your Xcode project (not `Fox.xcworkspace`). Then
link Fox-iOS or Fox-OSX to your test target.

And you're all set up! Dive right in by following the
[tutorial](http://fox-testing.readthedocs.org/en/latest/tutorial.html).

CocoaPods
---------

Add to your Podfile for you test target to have the latest stable version of
Fox:

    pod 'Fox', '~>1.0.1'

And then `pod install`.

And you're all set up! Dive right in by following the
[tutorial](http://fox-testing.readthedocs.org/en/latest/tutorial.html).

Reference
=========

If you want to see examples of usages, see the [full
reference](http://fox-testing.readthedocs.org/en/latest/generators_reference.html).

Data Generators
---------------

There are many data generators provided for generating data. Most of these
generators shrink to zero:

 - Numerically zero (or as close as possible)
 - Empty collection (or at least shrunk items)

Function                              | Generates      | Description
------------------------------------- |---------------:|-------------
FOXInteger                            | NSNumber *     | Generates random integers
FOXPositiveInteger                    | NSNumber *     | Generates random zero or positive integers
FOXNegativeInteger                    | NSNumber *     | Generates random zero or negative integers
FOXStrictPositiveInteger              | NSNumber *     | Generates random positive integers (non-zero)
FOXStrictNegativeInteger              | NSNumber *     | Generates random negative integers (non-zero)
FOXChoose                             | NSNumber *     | Generates random integers between the given range (inclusive)
FOXFloat                              | NSNumber *     | Generates random floats that conform to the IEEE standard.
FOXDouble                             | NSNumber *     | Generates random doubles that conforms to the IEEE standard.
FOXDecimalNumber                      | NSNumber *     | Generates random decimal numbers.
FOXReturn                             | id             | Always returns the given value. Does not shrink
FOXTuple                              | NSArray *      | Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
FOXTupleOfGenerators                  | NSArray *      | Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
FOXArray                              | NSArray *      | Generates random variable-sized arrays of generated values.
FOXArrayOfSize                        | NSArray *      | Generates random fixed-sized arrays of generated values. Values generated are in the same order as the generators provided.
FOXArrayOfSizeRange                   | NSArray *      | Generates random variable-sized arrays of generated values. Array size is within the given range (inclusive).
FOXDictionary                         | NSDictionary * | Generates random dictionaries of generated values. Keys are known values ahead of time. Specified in `@{<key>: <generator>}` form.
FOXSet                                | NSSet *        | Generates random sets of a given generated values.
FOXCharacter                          | NSString *     | Generates random 1-length sized character string. May be an unprintable character.
FOXAlphabetCharacter                  | NSString *     | Generates random 1-length sized character string. Only generates alphabetical letters.
FOXNumericCharacter                   | NSString *     | Generates random 1-length sized character string. Only generates digits.
FOXAlphanumericCharacter              | NSString *     | Generates random 1-length sized character string. Only generates alphanumeric.
FOXAsciiCharacter                     | NSString *     | Generates random 1-length sized character string. Only generates ascii characters.
FOXString                             | NSString *     | Generates random variable length strings. May be an unprintable string.
FOXStringOfLength                     | NSString *     | Generates random fixed length strings. May be an unprintable string.
FOXStringOfLengthRange                | NSString *     | Generates random length strings within the given range (inclusive). May be an unprintable string.
FOXAsciiString                        | NSString *     | Generates random variable length strings. Only generates ascii characters.
FOXAsciiStringOfLength                | NSString *     | Generates random fixed length strings. Only generates ascii characters.
FOXAsciiStringOfLengthRange           | NSString *     | Generates random variable length strings within the given range (inclusive). Only generates ascii characters.
FOXAlphabeticalString                 | NSString *     | Generates random variable length strings. Only generates alphabetical characters.
FOXAlphabeticalStringOfLength         | NSString *     | Generates random fixed length strings. Only generates alphabetical characters.
FOXAlphabeticalStringOfLengthRange    | NSString *     | Generates random variable length strings within the given range (inclusive). Only generates alphabetical characters.
FOXAlphanumericalString               | NSString *     | Generates random variable length strings. Only generates alphabetical characters.
FOXAlphanumericalStringOfLength       | NSString *     | Generates random fixed length strings. Only generates alphanumeric characters.
FOXAlphanumericalStringOfLengthRange  | NSString *     | Generates random variable length strings within the given range (inclusive). Only generates alphanumeric characters.
FOXNumericalString                    | NSString *     | Generates random variable length strings. Only generates numeric characters.
FOXNumericalStringOfLength            | NSString *     | Generates random fixed length strings. Only generates numeric characters.
FOXNumericalStringOfLengthRange       | NSString *     | Generates random variable length strings within the given range (inclusive). Only generates numeric characters.
FOXSimpleType                         | id             | Generates random simple types. A simple type does not compose with other types. May not be printable.
FOXPrintableSimpleType                | id             | Generates random simple types. A simple type does not compose with other types. Ensured to be printable.
FOXCompositeType                      | id             | Generates random composite types. A composite type composes with the given generator.
FOXAnyObject                          | id             | Generates random simple or composite types.
FOXAnyPrintableObject                 | id             | Generates random printable simple or composite types.

Computation Generators
----------------------

Also, you can compose some computation work on top of data generators. The resulting
generator adopts the same shrinking properties as the original generator.

Function                  | Description
------------------------- | ------------
FOXMap                    | Applies a block to each generated value.
FOXBind                   | Applies a block to the value that the original generator generates.
FOXResize                 | Overrides the given generator's size parameter with the specified size. Prevents shrinking.
FOXOptional               | Creates a new generator that has a 25% chance of returning `nil` instead of the provided generated value.
FOXFrequency              | Dispatches to one of many generators by probability. Takes an array of tuples (2-sized array) - `@[@[@probability_uint, generator]]`. Shrinking follows whatever generator is returned.
FOXSized                  | Encloses the given block to create generator that is dependent on the size hint generators receive when generating values.
FOXSuchThat               | Returns each generated value iff it satisfies the given block. If the filter excludes more than 10 values in a row, the resulting generator assumes it has reached maximum shrinking.
FOXSuchThatWithMaxTries   | Returns each generated value iff it satisfies the given block. If the filter excludes more than the given max tries in a row, the resulting generator assumes it has reached maximum shrinking. 
FOXOneOf                  | Returns generated values by randomly picking from an array of generators. Shrinking is dependent on the generator chosen.
FOXForAll                 | Asserts using the block and a generator and produces test assertion results (FOXPropertyResult). Shrinking tests against smaller values of the given generator.
FOXForSome                | Like FOXForAll, but allows the assertion block to "skip" potentially invalid test cases.
FOXCommands               | Generates arrays of FOXCommands that satisfies a given state machine.
FOXExecuteCommands        | Generates arrays of FOXExecutedCommands that satisfies a given state machine and executed against a subject. Can be passed to FOXExecutedSuccessfully to verify if the subject conforms to the state machine.


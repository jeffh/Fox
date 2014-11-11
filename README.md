PBT
===

Property Based Testing for Objective-C. Automatic generation of software tests.

You might have heard of this or similar technologies through the various genres
of testing frameworks and/or libraries:

 - [QuickCheck](http://www.haskell.org/haskellwiki/Introduction_to_QuickCheck1)
 - [test.check](https://github.com/clojure/test.check)
 - Property Based Testing
 - Model Based Testing
 - Fuzzy Testing
 - Black-Box Testing
 - Test Generation
 - Automatic Testing Tool

PBT is a port of test.check for Objective-C. Unlike some ports of QuickCheck,
PBT does implement shrinking (test.check does implement that too).

Better than Example-Based Tests
===============================

Test generation can provide a better coverage than example-based tests. Instead
of having to manually code test cases, PBT can generate tests for you.

Data Generation
---------------

The simpliest of test generation is providing random data.  PBT can generate
them for use if you can define specifications -- known properties of the
subject under test:

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

Once a failing example is produced, PBT will attempt to find the smallest
possible example that also exhibits the same failure:

    result.smallestFailingValue // @[@0, @0]; the smallest example that fails

Stateful Testing
----------------

How can you test stateful APIs? Represent the state changes as data! Using a
state machine, define a model of how your API is suppose to work. Here's one
for a queue:


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
    // Another way of adding a transition (see PBTStateTransition protocol)
    [stateMachine addTransition:[[PBTQueueRemoveTransition alloc] init]];

Now, you can generate tests that exercise an API:

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



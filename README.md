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




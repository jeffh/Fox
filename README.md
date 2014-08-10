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

PBT is a port of QuickCheck/test.check for Objective-C.

Better than example-based tests
-------------------------------

Instead of writing a variety of cases, PBT can generate them for use if you can
define specifications -- known properties of the subject under test:

    // testing addition
    PBTQuickCheck *checker = [[PBTQuickCheck alloc] init];
    // reads: for all integers x, y: x + y > x
    [checker checkWithNumberOfTests:100
                             forAll:PBTTuple(PBTInteger(), PBTInteger())
                               then:^PBTPropertyResult(NSArray *tuple) {
        NSInteger x = [tuple.firstObject integerValue];
        NSInteger y = [tuple.firstObject integerValue];
        return PBTRequire(x + y > x);
    }];


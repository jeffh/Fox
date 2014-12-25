#import <Cedar.h>
#import "FOX.h"
#import "NSArray+FastEnumerator.h"
#import <stdio.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXSequenceSpec)

describe(@"FOXSequence", ^{
    __block FOXSequence *subject;

    describe(@"concrete sequences", ^{
        describe(@"zero-element sequence", ^{
            beforeEach(^{
                subject = [FOXSequence sequence];
            });

            it(@"should have a count of zero", ^{
                [subject count] should equal(0);
            });

            it(@"should no elements", ^{
                [[subject objectEnumerator] allObjects] should be_empty;
                [NSArray arrayFromFastEnumerator:subject] should be_empty;
            });

            it(@"should return nil for firstObject", ^{
                [subject firstObject] should be_nil;
            });

            it(@"should return nil for remaining sequence", ^{
                [subject remainingSequence] should be_nil;
            });
        });

        describe(@"one-element sequence", ^{
            beforeEach(^{
                subject = [FOXSequence sequenceWithObject:@1];
            });

            it(@"should have a count of one", ^{
                [subject count] should equal(1);
            });

            it(@"should have the one element", ^{
                [[subject objectEnumerator] allObjects] should equal(@[@1]);
                [NSArray arrayFromFastEnumerator:subject] should equal(@[@1]);
            });

            it(@"should return the element as the firstObject", ^{
                [subject firstObject] should equal(@1);
            });

            it(@"should return nil for remaining sequence", ^{
                [subject remainingSequence] should be_nil;
            });
        });

        describe(@"many-element sequence", ^{
            __block id<FOXSequence> remainingSequence;

            beforeEach(^{
                remainingSequence = nice_fake_for(@protocol(FOXSequence));
                subject = [FOXSequence sequenceWithObject:@1
                                        remainingSequence:remainingSequence];

                remainingSequence stub_method(@selector(count)).and_return((NSUInteger)1);
                remainingSequence stub_method(@selector(firstObject)).and_return(@2);
            });

            it(@"should have a count of one plus remaining sequence's count", ^{
                [subject count] should equal(2);
            });

            it(@"should have the all the elements", ^{
                [[subject objectEnumerator] allObjects] should equal(@[@1, @2]);
                [NSArray arrayFromFastEnumerator:subject] should equal(@[@1, @2]);
            });

            it(@"should return the element as the firstObject", ^{
                [subject firstObject] should equal(@1);
            });

            it(@"should return nil for remaining sequence", ^{
                [subject remainingSequence] should be_same_instance_as(remainingSequence);
            });
        });
    });

    describe(@"lazy sequences", ^{
        describe(@"zero-element sequence", ^{
            beforeEach(^{
                subject = [FOXSequence lazySequenceFromBlock:^id<FOXSequence> {
                    return [FOXSequence sequence];
                }];
            });

            it(@"should have a count of zero", ^{
                [subject count] should equal(0);
            });

            it(@"should no elements", ^{
                [[subject objectEnumerator] allObjects] should be_empty;
                [NSArray arrayFromFastEnumerator:subject] should be_empty;
            });

            it(@"should return nil for firstObject", ^{
                [subject firstObject] should be_nil;
            });

            it(@"should return nil for remaining sequence", ^{
                [subject remainingSequence] should be_nil;
            });
        });

        describe(@"one-element sequence", ^{
            __block BOOL evaluated;

            beforeEach(^{
                evaluated = NO;

                subject = [FOXSequence lazySequenceFromBlock:^id<FOXSequence> {
                    evaluated = YES;
                    return [FOXSequence sequenceWithObject:@1];
                }];
            });

            it(@"should evalute when required", ^{
                evaluated should be_falsy;
                [subject count];
                evaluated should be_truthy;
            });

            it(@"should have a count of one", ^{
                [subject count] should equal(1);
            });

            it(@"should have the one element", ^{
                [[subject objectEnumerator] allObjects] should equal(@[@1]);
                [NSArray arrayFromFastEnumerator:subject] should equal(@[@1]);
            });

            it(@"should return the element as the firstObject", ^{
                [subject firstObject] should equal(@1);
            });

            it(@"should return nil for remaining sequence", ^{
                [subject remainingSequence] should be_nil;
            });
        });

        describe(@"many-element sequence", ^{
            __block id<FOXSequence> remainingSequence;
            __block BOOL evaluated;

            beforeEach(^{
                evaluated = NO;
                remainingSequence = nice_fake_for(@protocol(FOXSequence));

                subject = [FOXSequence lazySequenceFromBlock:^id<FOXSequence> {
                    evaluated = YES;
                    return [FOXSequence sequenceWithObject:@1 remainingSequence:remainingSequence];
                }];

                remainingSequence stub_method(@selector(count)).and_return((NSUInteger)1);
                remainingSequence stub_method(@selector(firstObject)).and_return(@2);
            });

            it(@"should evalute when required", ^{
                evaluated should be_falsy;
                [subject count];
                evaluated should be_truthy;
            });

            it(@"should have a count of one plus remaining sequence's count", ^{
                [subject count] should equal(2);
            });

            it(@"should have the all the elements", ^{
                [[subject objectEnumerator] allObjects] should equal(@[@1, @2]);
                [NSArray arrayFromFastEnumerator:subject] should equal(@[@1, @2]);
            });

            it(@"should return the element as the firstObject", ^{
                [subject firstObject] should equal(@1);
            });

            it(@"should return nil for remaining sequence", ^{
                [subject remainingSequence] should be_same_instance_as(remainingSequence);
            });

            it(@"should allow applying a block", ^{
                remainingSequence stub_method(@selector(sequenceByMapping:))
                .and_return(remainingSequence);
                id<FOXSequence> newSeq = [subject sequenceByMapping:^id(id value) {
                    return @([value integerValue] + 1);
                }];
                [[newSeq objectEnumerator] allObjects] should equal(@[@2, @2]);
            });
        });

        describe(@"concatenation", ^{
            it(@"should combine two sequences", ^{
                id<FOXSequence> seq1 = [FOXSequence sequenceWithObject:@1];
                id<FOXSequence> seq2 = [FOXSequence sequenceWithObject:@2];
                [seq1 sequenceByAppending:seq2] should equal([FOXSequence sequenceFromArray:@[@1, @2]]);
            });
        });

        describe(@"subset", ^{
            it(@"should generate all subsets of sequences for two elements", ^{
                id<FOXSequence> s = [FOXSequence sequenceFromArray:@[@1, @2]];
                id<FOXSequence> expectedSeq = [FOXSequence sequenceFromArray:@[[FOXSequence sequence],
                                                                               [FOXSequence sequenceFromArray:@[@1]],
                                                                               [FOXSequence sequenceFromArray:@[@2]],
                                                                               [FOXSequence sequenceFromArray:@[@1, @2]]]];
                [FOXSequence subsetsOfSequence:s] should equal(expectedSeq);
            });

            it(@"should generate all subsets of sequences", ^{
                id<FOXSequence> s = [FOXSequence sequenceFromArray:@[@1, @2, @3]];
                id<FOXSequence> expectedSeq = [FOXSequence sequenceFromArray:@[[FOXSequence sequence],
                                                                               [FOXSequence sequenceFromArray:@[@1]],
                                                                               [FOXSequence sequenceFromArray:@[@2]],
                                                                               [FOXSequence sequenceFromArray:@[@3]],
                                                                               [FOXSequence sequenceFromArray:@[@1, @2]],
                                                                               [FOXSequence sequenceFromArray:@[@1, @3]],
                                                                               [FOXSequence sequenceFromArray:@[@2, @3]],
                                                                               [FOXSequence sequenceFromArray:@[@1, @2, @3]]]];
                [FOXSequence subsetsOfSequence:s] should equal(expectedSeq);
            });
        });
    });
});

SPEC_END

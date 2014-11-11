#import <Cedar/Cedar.h>
#import "PBT.h"
#import "NSArray+FastEnumerator.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTSequenceSpec)

describe(@"PBTSequence", ^{
    __block PBTSequence *subject;

    describe(@"concrete sequences", ^{
        describe(@"zero-element sequence", ^{
            beforeEach(^{
                subject = [PBTSequence sequence];
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
                subject = [PBTSequence sequenceWithObject:@1];
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
            __block id<PBTSequence> remainingSequence;

            beforeEach(^{
                remainingSequence = nice_fake_for(@protocol(PBTSequence));
                subject = [PBTSequence sequenceWithObject:@1
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
                subject = [PBTSequence lazySequenceFromBlock:^id<PBTSequence>{
                    return [PBTSequence sequence];
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

                subject = [PBTSequence lazySequenceFromBlock:^id<PBTSequence>{
                    evaluated = YES;
                    return [PBTSequence sequenceWithObject:@1];
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
            __block id<PBTSequence> remainingSequence;
            __block BOOL evaluated;

            beforeEach(^{
                evaluated = NO;
                remainingSequence = nice_fake_for(@protocol(PBTSequence));

                subject = [PBTSequence lazySequenceFromBlock:^id<PBTSequence>{
                    evaluated = YES;
                    return [PBTSequence sequenceWithObject:@1 remainingSequence:remainingSequence];
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
                remainingSequence stub_method(@selector(sequenceByApplyingBlock:))
                .and_return(remainingSequence);
                id<PBTSequence> newSeq = [subject sequenceByApplyingBlock:^id(id value) {
                    return @([value integerValue] + 1);
                }];
                [[newSeq objectEnumerator] allObjects] should equal(@[@2, @2]);
            });
        });
        
        describe(@"concatenation", ^{
            it(@"should combine two sequences", ^{
                id<PBTSequence> seq1 = [PBTSequence sequenceWithObject:@1];
                id<PBTSequence> seq2 = [PBTSequence sequenceWithObject:@2];
                [seq1 sequenceByConcatenatingSequence:seq2] should equal([PBTSequence sequenceFromArray:@[@1, @2]]);
            });
        });
    });
});

SPEC_END

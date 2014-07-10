#import "PBTConcreteSequence.h"
#import "NSArray+FastEnumerator.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTConcreteSequenceSpec)

describe(@"PBTConcreteSequence", ^{
    __block PBTConcreteSequence *subject;

    describe(@"zero-element sequence", ^{
        beforeEach(^{
            subject = [[PBTConcreteSequence alloc] init];
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
            subject = [[PBTConcreteSequence alloc] initWithObject:@1];
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
            subject = [[PBTConcreteSequence alloc] initWithObject:@1
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

SPEC_END

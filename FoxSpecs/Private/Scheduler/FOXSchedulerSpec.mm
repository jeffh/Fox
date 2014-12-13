#import <Cedar/Cedar.h>
#import "FOXScheduler.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXSchedulerSpec)

describe(@"FOXScheduler", ^{
    __block FOXSchedulerPtr subject;

    beforeEach(^{
        subject = FOXSchedulerCreateWithAlgorithm(nil, &FOXRandomScheduling);
    });

    afterEach(^{
        FOXSchedulerRelease(subject);
    });

    __block BOOL executedStartBlock;
    subjectAction(^{
        executedStartBlock = NO;
        FOXSchedulerStart(subject, ^{
            executedStartBlock = YES;
        });
    });

    it(@"should execute the start block", ^{
        executedStartBlock should be_truthy;
    });

    context(@"with one thread", ^{
        __block NSUInteger threadCounter;
        __block NSString *value;

        beforeEach(^{
            threadCounter = 0;
            value = nil;
            FOXSchedulerThreadPtr t = FOXSchedulerAddSchedulerThread(subject);
            FOXSchedulerThreadEnqueue(t, ^{
                threadCounter++;
                value = @"a";
            });
            FOXSchedulerThreadEnqueue(t, ^{
                threadCounter++;
                value = @"b";
            });
            FOXSchedulerThreadEnqueueExit(t);
        });

        it(@"should execute the start block", ^{
            executedStartBlock should be_truthy;
        });

        it(@"should preserve the specified order", ^{
            value should equal(@"b");
        });

        it(@"should execute all blocks", ^{
            threadCounter should equal(2);
        });
    });

    context(@"with two threads", ^{
        __block NSMutableArray *values;

        beforeEach(^{
            values = [NSMutableArray array];

            FOXSchedulerThreadPtr t1 = FOXSchedulerAddSchedulerThread(subject);
            FOXSchedulerThreadEnqueue(t1, ^{
                [values addObject:@1];
            });
            FOXSchedulerThreadEnqueue(t1, ^{
                [values addObject:@2];
            });
            FOXSchedulerThreadEnqueueExit(t1);

            FOXSchedulerThreadPtr t2 = FOXSchedulerAddSchedulerThread(subject);
            FOXSchedulerThreadEnqueue(t2, ^{
                [values addObject:@3];
            });
            FOXSchedulerThreadEnqueue(t2, ^{
                [values addObject:@4];
            });
            FOXSchedulerThreadEnqueueExit(t2);
        });

        it(@"should execute in thread order", ^{
            values.count should equal(4);
            values should contain(@1);
            values should contain(@2);
            values should contain(@3);
            values should contain(@4);
        });

        it(@"should execute the start block", ^{
            executedStartBlock should be_truthy;
        });
    });

    context(@"with two threads and yielding", ^{
        __block NSMutableArray *values;

        beforeEach(^{
            values = [NSMutableArray array];

            FOXSchedulerThreadPtr t1 = FOXSchedulerAddSchedulerThread(subject);
            FOXSchedulerThreadEnqueue(t1, ^{
                [values addObject:@1];
                FOXSchedulerYield();
                [values addObject:@5];
            });
            FOXSchedulerThreadEnqueue(t1, ^{
                [values addObject:@2];
            });
            FOXSchedulerThreadEnqueueExit(t1);

            FOXSchedulerThreadPtr t2 = FOXSchedulerAddSchedulerThread(subject);
            FOXSchedulerThreadEnqueue(t2, ^{
                [values addObject:@3];
            });
            FOXSchedulerThreadEnqueue(t2, ^{
                [values addObject:@4];
            });
            FOXSchedulerThreadEnqueueExit(t2);
        });

        it(@"should execute in thread order", ^{
            values.count should equal(5);
            values should contain(@1);
            values should contain(@2);
            values should contain(@3);
            values should contain(@4);
            values should contain(@5);
        });

        it(@"should always have 1 before 5", ^{
            NSInteger indexOf1 = [values indexOfObject:@1];
            NSInteger indexOf5 = [values indexOfObject:@5];
            indexOf1 should be_less_than(indexOf5);
        });

        it(@"should execute the start block", ^{
            executedStartBlock should be_truthy;
        });
    });
});

SPEC_END

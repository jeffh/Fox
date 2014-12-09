#import "FOXRunner.h"
#import "FOXGenerator.h"
#import "FOXRoseTree.h"
#import "FOXDeterministicRandom.h"
#import "FOXSequence.h"
#import "FOXRunnerResult.h"
#import "FOXStandardReporter.h"
#import "FOXReporter.h"
#import "FOXPropertyResult.h"
#import "FOXPropertyGenerators.h"
#import "FOXEnvironment.h"

typedef struct _FOXShrinkReport {
    NSUInteger depth;
    NSUInteger numberOfNodesVisited;
    CFTypeRef smallestArgument;
    CFTypeRef smallestUncaughtException;
} FOXShrinkReport;


@implementation FOXRunner

+ (instancetype)assertInstance
{
    static FOXRunner *__check;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __check = [[FOXRunner alloc] init];
    });
    return __check;
}

- (instancetype)init
{
    return [self initWithReporter:nil];
}

- (instancetype)initWithReporter:(id<FOXReporter>)reporter
{
    return [self initWithReporter:reporter random:[[FOXDeterministicRandom alloc] init]];
}

- (instancetype)initWithReporter:(id<FOXReporter>)reporter random:(id<FOXRandom>)random
{
    self = [super init];
    if (self) {
        self.random = random;
        self.reporter = reporter;
    }
    return self;
}

#pragma mark - Public

- (FOXRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                   property:(id<FOXGenerator>)property
                                       seed:(NSUInteger)seed
                                    maxSize:(NSUInteger)maxSize
{
    NSUInteger currentTestNumber = 0;
    [self.random setSeed:seed];
    [self.reporter runnerWillRunWithSeed:seed];

    while (true) {
        for (NSUInteger size = 0; size < maxSize; size++) {
            if (currentTestNumber == totalNumberOfTests) {
                return [self successfulReportWithNumberOfTests:totalNumberOfTests
                                                       maxSize:maxSize
                                                          seed:seed];
            }

            ++currentTestNumber;

            FOXRoseTree *tree = [property lazyTreeWithRandom:self.random maximumSize:size];
            FOXPropertyResult *result = tree.value;
            NSAssert([result isKindOfClass:[FOXPropertyResult class]],
                     @"Expected property generator to return FOXPropertyResult, got %@",
                     NSStringFromClass([result class]));


            [self.reporter runnerWillVerifyTestNumber:currentTestNumber
                                      withMaximumSize:size];

            if ([result hasFailedOrRaisedException]) {
                return [self failureReportWithNumberOfTests:currentTestNumber
                                            failureRoseTree:tree
                                                failingSize:size
                                                    maxSize:maxSize
                                                       seed:seed];
            } else if (result.status == FOXPropertyStatusSkipped) {
                [self.reporter runnerDidSkipTestNumber:totalNumberOfTests
                                        propertyResult:result];
            } else {
                [self.reporter runnerDidPassTestNumber:totalNumberOfTests
                                        propertyResult:result];
            }
        }
    }
}

#pragma mark - Public Convenience Methods

- (FOXRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                   property:(id<FOXGenerator>)property
                                       seed:(NSUInteger)seed
{
    return [self resultForNumberOfTests:totalNumberOfTests
                               property:property
                                   seed:seed
                                maxSize:FOXGetMaximumSize()];
}

- (FOXRunnerResult *)resultForNumberOfTests:(NSUInteger)numberOfTests
                                   property:(id<FOXGenerator>)property
{
    return [self resultForNumberOfTests:numberOfTests
                               property:property
                                   seed:FOXGetSeed()];
}

#pragma mark - Private

- (FOXRunnerResult *)successfulReportWithNumberOfTests:(NSUInteger)numberOfTests
                                               maxSize:(NSUInteger)maxSize
                                                  seed:(NSUInteger)seed
{
    FOXRunnerResult *result = [[FOXRunnerResult alloc] init];
    result.succeeded = YES;
    result.numberOfTests = numberOfTests;
    result.seed = seed;
    result.maxSize = maxSize;

    [self.reporter runnerDidPassNumberOfTests:numberOfTests
                                   withResult:result];
    [self.reporter runnerDidRunWithResult:result];
    return result;
}

- (FOXRunnerResult *)failureReportWithNumberOfTests:(NSUInteger)numberOfTests
                                    failureRoseTree:(FOXRoseTree *)failureRoseTree
                                        failingSize:(NSUInteger)failingSize
                                            maxSize:(NSUInteger)maxSize
                                               seed:(NSUInteger)seed
{
    [self.reporter runnerWillShrinkFailingTestNumber:numberOfTests
                            failedWithPropertyResult:failureRoseTree.value];
    FOXPropertyResult *propertyResult = failureRoseTree.value;
    FOXShrinkReport report = [self shrinkReportForRoseTree:failureRoseTree
                                             numberOfTests:numberOfTests];
    FOXRunnerResult *result = [[FOXRunnerResult alloc] init];
    result.numberOfTests = numberOfTests;
    result.seed = seed;
    result.maxSize = maxSize;
    result.failingSize = failingSize;
    result.failingValue = propertyResult.generatedValue;
    result.failingException = propertyResult.uncaughtException;
    result.shrinkDepth = report.depth;
    result.shrinkNodeWalkCount = report.numberOfNodesVisited;
    result.smallestFailingValue = CFBridgingRelease(report.smallestArgument);
    result.smallestFailingException = CFBridgingRelease(report.smallestUncaughtException);

    [self.reporter runnerDidFailTestNumber:numberOfTests
                                withResult:result];
    [self.reporter runnerDidRunWithResult:result];

    return result;
}

- (FOXShrinkReport)shrinkReportForRoseTree:(FOXRoseTree *)failureRoseTree
                             numberOfTests:(NSUInteger)numberOfTests
{
    NSUInteger numberOfNodesVisited = 0;
    NSUInteger depth = 0;
    id<FOXSequence> shrinkChoicesAtDepth = failureRoseTree.children;
    FOXPropertyResult *currentSmallest = failureRoseTree.value;

    while ([shrinkChoicesAtDepth firstObject]) {
        @autoreleasepool {
            FOXRoseTree *firstTree = [shrinkChoicesAtDepth firstObject];

            // "try" next smallest permutation
            FOXPropertyResult *smallestCandidate = firstTree.value;
            if ([smallestCandidate hasFailedOrRaisedException]) {
                currentSmallest = smallestCandidate;

                if ([firstTree.children firstObject]) {
                    shrinkChoicesAtDepth = firstTree.children;
                    ++depth;
                } else {
                    shrinkChoicesAtDepth = [shrinkChoicesAtDepth remainingSequence];
                }
            } else {
                shrinkChoicesAtDepth = [shrinkChoicesAtDepth remainingSequence];
            }

            ++numberOfNodesVisited;
            [self.reporter runnerDidShrinkFailingTestNumber:numberOfTests
                                         withPropertyResult:smallestCandidate];
        }
    }

    return (FOXShrinkReport) {
        .depth=depth,
        .numberOfNodesVisited=numberOfNodesVisited,
        .smallestArgument=CFBridgingRetain(currentSmallest.generatedValue),
        .smallestUncaughtException=CFBridgingRetain(currentSmallest.uncaughtException),
    };
}

@end

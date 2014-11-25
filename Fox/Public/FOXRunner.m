#import "FOXRunner.h"
#import "FOXRoseTree.h"
#import "FOXDeterministicRandom.h"
#import "FOXSequence.h"
#import "FOXRunnerResult.h"
#import "FOXStandardReporter.h"


const NSUInteger FOXDefaultNumberOfTests = 500;
const NSUInteger FOXDefaultMaximumSize = 200;


typedef struct _FOXShrinkReport {
    NSUInteger depth;
    NSUInteger numberOfNodesVisited;
    void *smallestArgument;
    void *smallestUncaughtException;
} FOXShrinkReport;


@interface FOXRunner ()

@property (nonatomic) id <FOXRandom> random;
@property (nonatomic) id <FOXReporter> reporter;

@end


@implementation FOXRunner

+ (instancetype)sharedInstance
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

- (instancetype)initWithReporter:(id <FOXReporter>)reporter
{
    return [self initWithReporter:reporter random:[[FOXDeterministicRandom alloc] init]];
}

- (instancetype)initWithReporter:(id <FOXReporter>)reporter random:(id <FOXRandom>)random
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
                                   property:(id <FOXGenerator>)property
                                       seed:(uint32_t)seed
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
            } else {
                [self.reporter runnerDidPassTestNumber:totalNumberOfTests];
            }
        }
    }
}

#pragma mark - Public Convenience Methods

- (FOXRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                   property:(id <FOXGenerator>)property
                                       seed:(uint32_t)seed
{
    return [self resultForNumberOfTests:totalNumberOfTests
                               property:property
                                   seed:seed
                                maxSize:FOXDefaultMaximumSize];
}

- (FOXRunnerResult *)resultForNumberOfTests:(NSUInteger)numberOfTests
                                   property:(id <FOXGenerator>)property
{
    return [self resultForNumberOfTests:numberOfTests
                               property:property
                                   seed:(uint32_t) time(NULL)];
}

- (FOXRunnerResult *)resultForNumberOfTests:(NSUInteger)numberOfTests
                                    forSome:(id<FOXGenerator>)values
                                       then:(FOXPropertyStatus (^)(id generatedValue))then
{
    return [self resultForNumberOfTests:numberOfTests
                               property:FOXForSome(values, then)];
}

#pragma mark - Private

- (FOXRunnerResult *)successfulReportWithNumberOfTests:(NSUInteger)numberOfTests
                                               maxSize:(NSUInteger)maxSize
                                                  seed:(uint32_t)seed
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
                                               seed:(uint32_t)seed
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
    id <FOXSequence> shrinkChoices = failureRoseTree.children;
    FOXPropertyResult *currentSmallest = failureRoseTree.value;

    while ([shrinkChoices firstObject]) {
        FOXRoseTree *firstTree = [shrinkChoices firstObject];

        // "try" next smallest permutation
        FOXPropertyResult *smallestCandidate = firstTree.value;
        if ([smallestCandidate hasFailedOrRaisedException]) {
            currentSmallest = smallestCandidate;

            if ([firstTree.children firstObject] && [firstTree.children firstObject]) {
                shrinkChoices = firstTree.children;
                ++depth;
            } else {
                shrinkChoices = [shrinkChoices remainingSequence];
            }
        } else {
            shrinkChoices = [shrinkChoices remainingSequence];
        }

        ++numberOfNodesVisited;
        [self.reporter runnerDidShrinkFailingTestNumber:numberOfTests
                                     withPropertyResult:smallestCandidate];
    }

    return (FOXShrinkReport) {
        .depth=depth,
        .numberOfNodesVisited=numberOfNodesVisited,
        .smallestArgument=(void *) CFBridgingRetain(currentSmallest.generatedValue),
        .smallestUncaughtException=(void *) CFBridgingRetain(currentSmallest.uncaughtException),
    };
}

@end

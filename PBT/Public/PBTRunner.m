#import "PBTRunner.h"
#import "PBTRoseTree.h"
#import "PBTDeterministicRandom.h"
#import "PBTSequence.h"
#import "PBTRunnerResult.h"
#import "PBTStandardReporter.h"


typedef struct _PBTShrinkReport {
    NSUInteger depth;
    NSUInteger numberOfNodesVisited;
    void *smallestArgument;
    void *smallestUncaughtException;
} PBTShrinkReport;


@interface PBTRunner ()

@property (nonatomic) id <PBTRandom> random;
@property (nonatomic) id <PBTReporter> reporter;

@end


@implementation PBTRunner

+ (instancetype)sharedInstance
{
    static PBTRunner *__check;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __check = [[PBTRunner alloc] init];
    });
    return __check;
}

- (instancetype)init
{
    return [self initWithReporter:[[PBTStandardReporter alloc] initWithFile:stdout]];
}

- (instancetype)initWithReporter:(id <PBTReporter>)reporter
{
    return [self initWithReporter:reporter random:[[PBTDeterministicRandom alloc] init]];
}

- (instancetype)initWithReporter:(id <PBTReporter>)reporter random:(id <PBTRandom>)random
{
    self = [super init];
    if (self) {
        self.random = random;
        self.reporter = reporter;
    }
    return self;
}

#pragma mark - Public

- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                  property:(id <PBTGenerator>)property
                                      seed:(uint32_t)seed
                                   maxSize:(NSUInteger)maxSize
{
    NSUInteger currentTestNumber = 0;
    [self.random setSeed:seed];
    [self.reporter checkerWillRunWithSeed:seed];

    while (true) {
        for (NSUInteger size = 0; size < maxSize; size++) {
            if (currentTestNumber == totalNumberOfTests) {
                return [self successfulReportWithNumberOfTests:totalNumberOfTests
                                                       maxSize:maxSize
                                                          seed:seed];
            }

            ++currentTestNumber;

            PBTRoseTree *tree = [property lazyTreeWithRandom:self.random maximumSize:size];
            PBTPropertyResult *result = tree.value;
            NSAssert([result isKindOfClass:[PBTPropertyResult class]],
                    @"Expected property generator to return PBTPropertyResult, got %@",
                    NSStringFromClass([result class]));


            [self.reporter checkerWillVerifyTestNumber:currentTestNumber
                                       withMaximumSize:size];

            if ([result hasFailedOrRaisedException]) {
                return [self failureReportWithNumberOfTests:currentTestNumber
                                            failureRoseTree:tree
                                                failingSize:size
                                                    maxSize:maxSize
                                                       seed:seed];
            } else {
                [self.reporter checkerDidPassTestNumber:totalNumberOfTests];
            }
        }
    }
}

#pragma mark - Public Convenience Methods

- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                  property:(id <PBTGenerator>)property
                                      seed:(uint32_t)seed
{
    return [self resultForNumberOfTests:totalNumberOfTests
                               property:property
                                   seed:seed
                                maxSize:50];
}

- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)numberOfTests
                                  property:(id <PBTGenerator>)property
{
    return [self resultForNumberOfTests:numberOfTests
                               property:property
                                   seed:(uint32_t) time(NULL)];
}

- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)numberOfTests
                                    forAll:(id <PBTGenerator>)values
                                      then:(PBTPropertyStatus (^)(id generatedValue))then
{
    return [self resultForNumberOfTests:numberOfTests
                               property:[PBTProperty forAll:values then:then]];
}

- (void)checkWithNumberOfTests:(NSUInteger)totalNumberOfTests
                      property:(id <PBTGenerator>)property
                          seed:(uint32_t)seed
                       maxSize:(NSUInteger)maxSize
{
    [self checkResult:[self resultForNumberOfTests:totalNumberOfTests property:property seed:seed maxSize:maxSize]];
}

- (void)checkWithNumberOfTests:(NSUInteger)numberOfTests property:(id <PBTGenerator>)property
{
    [self checkResult:[self resultForNumberOfTests:numberOfTests property:property]];
}

- (void)checkWithNumberOfTests:(NSUInteger)numberOfTests forAll:(id <PBTGenerator>)values then:(PBTPropertyStatus (^)(id generatedValue))then
{
    [self checkResult:[self resultForNumberOfTests:numberOfTests forAll:values then:then]];
}

- (void)checkWithNumberOfTests:(NSUInteger)totalNumberOfTests property:(id <PBTGenerator>)property seed:(uint32_t)seed
{
    [self checkResult:[self resultForNumberOfTests:totalNumberOfTests property:property seed:seed]];
}

#pragma mark - Private

- (void)checkResult:(PBTRunnerResult *)result
{
    NSAssert(result.succeeded, @"=== Failed ===\n%@", result);
}

- (PBTRunnerResult *)successfulReportWithNumberOfTests:(NSUInteger)numberOfTests
                                              maxSize:(NSUInteger)maxSize
                                                 seed:(uint32_t)seed
{
    PBTRunnerResult *result = [[PBTRunnerResult alloc] init];
    result.succeeded = YES;
    result.numberOfTests = numberOfTests;
    result.seed = seed;
    result.maxSize = maxSize;

    [self.reporter checkerDidPassNumberOfTests:numberOfTests
                                    withResult:result];
    return result;
}

- (PBTRunnerResult *)failureReportWithNumberOfTests:(NSUInteger)numberOfTests
                                   failureRoseTree:(PBTRoseTree *)failureRoseTree
                                       failingSize:(NSUInteger)failingSize
                                           maxSize:(NSUInteger)maxSize
                                              seed:(uint32_t)seed
{
    [self.reporter checkerWillShrinkFailingTestNumber:numberOfTests
                             failedWithPropertyResult:failureRoseTree.value];
    PBTPropertyResult *propertyResult = failureRoseTree.value;
    PBTShrinkReport report = [self shrinkReportForRoseTree:failureRoseTree
                                             numberOfTests:numberOfTests];
    PBTRunnerResult *result = [[PBTRunnerResult alloc] init];
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

    [self.reporter checkerDidFailTestNumber:numberOfTests
                                 withResult:result];

    return result;
}

- (PBTShrinkReport)shrinkReportForRoseTree:(PBTRoseTree *)failureRoseTree
                             numberOfTests:(NSUInteger)numberOfTests
{
    NSUInteger numberOfNodesVisited = 0;
    NSUInteger depth = 0;
    id <PBTSequence> shrinkChoices = failureRoseTree.children;
    PBTPropertyResult *currentSmallest = failureRoseTree.value;

    while ([shrinkChoices firstObject]) {
        PBTRoseTree *firstTree = [shrinkChoices firstObject];
        PBTPropertyResult *smallestCandidate = firstTree.value;
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
        [self.reporter checkerShrankFailingTestNumber:numberOfTests
                                   withPropertyResult:smallestCandidate];
    }

    return (PBTShrinkReport) {
            .depth=depth,
            .numberOfNodesVisited=numberOfNodesVisited,
            .smallestArgument=(void *) CFBridgingRetain(currentSmallest.generatedValue),
            .smallestUncaughtException=(void *) CFBridgingRetain(currentSmallest.uncaughtException),
    };
}

@end

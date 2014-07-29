#import "PBTQuickCheck.h"
#import "PBTRoseTree.h"
#import "PBTRandom.h"
#import "PBTSequence.h"
#import "PBTQuickCheckResult.h"


@interface PBTQuickCheck ()

@property (nonatomic) id<PBTRandom> random;

@end


@implementation PBTQuickCheck

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.random = [[PBTRandom alloc] init];
    }
    return self;
}

- (PBTQuickCheckResult *)checkWithNumberOfTests:(NSUInteger)totalNumberOfTests
                                       property:(id<PBTGenerator>)property
                                           seed:(uint32_t)seed
                                        maxSize:(NSUInteger)maxSize
{
    NSUInteger currentTestNumber = 0;
    [self.random setSeed:seed];
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
            if ([result hasFailedOrRaisedException]) {
                return [self failureReportWithNumberOfTests:currentTestNumber
                                            failureRoseTree:tree
                                                failingSize:size
                                                    maxSize:maxSize
                                                       seed:seed];
            }
        }
    }
}

- (PBTQuickCheckResult *)checkWithNumberOfTests:(NSUInteger)numberOfTests
                                       property:(id<PBTGenerator>)property
{
    return [self checkWithNumberOfTests:numberOfTests
                               property:property
                                   seed:(uint32_t)time(NULL)
                                maxSize:50];
}

- (PBTQuickCheckResult *)checkWithNumberOfTests:(NSUInteger)numberOfTests
                                         forAll:(id<PBTGenerator>)values
                                           then:(PBTPropertyStatus (^)(id generatedValue))then
{
    return [self checkWithNumberOfTests:numberOfTests
                               property:[PBTProperty forAll:values then:then]];
}


#pragma mark - Private

- (PBTQuickCheckResult *)successfulReportWithNumberOfTests:(NSUInteger)numberOfTests
                                                   maxSize:(NSUInteger)maxSize
                                                      seed:(uint32_t)seed
{
    PBTQuickCheckResult *result = [[PBTQuickCheckResult alloc] init];
    result.succeeded = YES;
    result.numberOfTests = numberOfTests;
    result.seed = seed;
    result.maxSize = maxSize;
    return result;
}

- (PBTQuickCheckResult *)failureReportWithNumberOfTests:(NSUInteger)numberOfTests
                                        failureRoseTree:(PBTRoseTree *)failureRoseTree
                                            failingSize:(NSUInteger)failingSize
                                                maxSize:(NSUInteger)maxSize
                                                   seed:(uint32_t)seed
{
    PBTPropertyResult *propertyResult = failureRoseTree.value;
    NSDictionary *shrinkReport = [self shrinkReportForRoseTree:failureRoseTree];
    PBTQuickCheckResult *result = [[PBTQuickCheckResult alloc] init];
    result.numberOfTests = numberOfTests;
    result.seed = seed;
    result.maxSize = maxSize;
    result.failingSize = failingSize;
    result.failingArguments = propertyResult.generatedValue;
    result.shrinkDepth = [shrinkReport[@"depth"] unsignedIntegerValue];
    result.shrinkNodeWalkCount = [shrinkReport[@"numberOfNodesVisited"] unsignedIntegerValue];
    result.smallestFailingArguments = shrinkReport[@"smallest"];
    return result;
}

- (NSDictionary *)shrinkReportForRoseTree:(PBTRoseTree *)failureRoseTree
{
    NSUInteger numberOfNodesVisited = 0;
    NSUInteger depth = 0;
    id<PBTSequence> shrinkChoices = failureRoseTree.children;
    PBTPropertyResult *currentSmallest = failureRoseTree.value;
    fprintf(stderr, "Shrinking");
    NSLog(@"================> ~> %@", [shrinkChoices firstObject]);
    while ([shrinkChoices firstObject]) {
        fprintf(stderr, ".");
        fflush(stderr);
        PBTRoseTree *firstTree = [shrinkChoices firstObject];
        PBTPropertyResult *smallestCandidate = firstTree.value;
        if ([smallestCandidate hasFailedOrRaisedException]) {
            currentSmallest = smallestCandidate;

            if ([firstTree.children count]) {
                shrinkChoices = firstTree.children;
                ++depth;
            } else {
                shrinkChoices = [shrinkChoices remainingSequence];
            }
        } else {
            shrinkChoices = [shrinkChoices remainingSequence];
        }

        ++numberOfNodesVisited;
    }
    fprintf(stderr, "\n");
    fflush(stderr);
    return @{@"numberOfNodesVisited": @(numberOfNodesVisited),
             @"depth": @(depth),
             @"result": @(currentSmallest.status),
             @"smallest": currentSmallest.generatedValue ?: [NSNull null]};
}

@end

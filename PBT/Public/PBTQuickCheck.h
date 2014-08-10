#import "PBTGenerator.h"
#import "PBTProperty.h"


@class PBTQuickCheckResult;
@protocol PBTQuickCheckReporter;


@interface PBTQuickCheck : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init;
- (instancetype)initWithReporter:(id<PBTQuickCheckReporter>)reporter;
- (instancetype)initWithReporter:(id<PBTQuickCheckReporter>)reporter random:(id<PBTRandom>)random;

- (PBTQuickCheckResult *)checkWithNumberOfTests:(NSUInteger)numberOfTests
                                       property:(id<PBTGenerator>)property;
- (PBTQuickCheckResult *)checkWithNumberOfTests:(NSUInteger)numberOfTests
                                         forAll:(id<PBTGenerator>)values
                                           then:(PBTPropertyStatus (^)(id generatedValue))then;
- (PBTQuickCheckResult *)checkWithNumberOfTests:(NSUInteger)totalNumberOfTests
                                       property:(id<PBTGenerator>)property
                                           seed:(uint32_t)seed
                                        maxSize:(NSUInteger)maxSize;


@end


@protocol PBTQuickCheckReporter <NSObject>

- (void)checkerWillRunWithSeed:(uint32_t)randomSeed;

- (void)checkerWillVerifyTestNumber:(NSUInteger)testNumber
                    withMaximumSize:(NSUInteger)maxSize;

- (void)checkerDidPassTestNumber:(NSUInteger)testNumber;

- (void)checkerWillShrinkFailingTestNumber:(NSUInteger)testNumber
                  failedWithPropertyResult:(PBTPropertyResult *)result;
- (void)checkerShrankFailingTestNumber:(NSUInteger)testNumber
                    withPropertyResult:(PBTPropertyResult *)result;
- (void)checkerDidFailTestNumber:(NSUInteger)testNumber
                      withResult:(PBTQuickCheckResult *)result;

- (void)checkerDidPassNumberOfTests:(NSUInteger)testNumber
                         withResult:(PBTQuickCheckResult *)result;


@end

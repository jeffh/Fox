#import <Foundation/Foundation.h>
#import "PBTGenerator.h"
#import "PBTProperty.h"


@class PBTQuickCheckResult;
@protocol PBTQuickCheckReporter;


@interface PBTQuickCheck : NSObject

- (instancetype)init;
- (instancetype)initWithReporter:(id<PBTQuickCheckReporter>)reporter;
- (instancetype)initWithReporter:(id<PBTQuickCheckReporter>)reporter random:(id<PBTRandom>)random;

- (PBTQuickCheckResult *)checkWithNumberOfTests:(NSUInteger)numberOfTests
                                       property:(id<PBTGenerator>)property;
- (PBTQuickCheckResult *)checkWithNumberOfTests:(NSUInteger)numberOfTests
                                         forAll:(id<PBTGenerator>)values
                                           then:(PBTPropertyStatus (^)(id generatedValue))then;


@end


@protocol PBTQuickCheckReporter <NSObject>

- (void)checkerWillRunWithSeed:(uint32_t)randomSeed;

- (void)checkerWillVerifyTestNumber:(NSUInteger)testNumber
                    withMaximumSize:(NSUInteger)maxSize;

- (void)checkerDidPassTestNumber:(NSUInteger)testNumber;

- (void)checkerWillShrinkFailingTestNumber:(NSUInteger)testNumber;
- (void)checkerShrankFailingTestNumber:(NSUInteger)testNumber;
- (void)checkerDidFailTestNumber:(NSUInteger)testNumber
                      withResult:(PBTQuickCheckResult *)result;

- (void)checkerDidPassNumberOfTests:(NSUInteger)testNumber
                         withResult:(PBTQuickCheckResult *)result;


@end

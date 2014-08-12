#import <Foundation/Foundation.h>


@class PBTRunnerResult;
@class PBTPropertyResult;


@protocol PBTReporter <NSObject>

- (void)runnerWillRunWithSeed:(uint32_t)randomSeed;

- (void)runnerWillVerifyTestNumber:(NSUInteger)testNumber
                   withMaximumSize:(NSUInteger)maxSize;

- (void)runnerDidPassTestNumber:(NSUInteger)testNumber;

- (void)runnerWillShrinkFailingTestNumber:(NSUInteger)testNumber
                 failedWithPropertyResult:(PBTPropertyResult *)result;
- (void)runnerDidShrinkFailingTestNumber:(NSUInteger)testNumber
                      withPropertyResult:(PBTPropertyResult *)result;
- (void)runnerDidFailTestNumber:(NSUInteger)testNumber
                     withResult:(PBTRunnerResult *)result;

- (void)runnerDidPassNumberOfTests:(NSUInteger)testNumber
                        withResult:(PBTRunnerResult *)result;

- (void)runnerDidRunWithResult:(PBTRunnerResult *)result;

@end

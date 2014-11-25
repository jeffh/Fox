#import <Foundation/Foundation.h>


@class FOXRunnerResult;
@class FOXPropertyResult;


@protocol FOXReporter<NSObject>

- (void)runnerWillRunWithSeed:(uint32_t)randomSeed;

- (void)runnerWillVerifyTestNumber:(NSUInteger)testNumber
                   withMaximumSize:(NSUInteger)maxSize;

- (void)runnerDidPassTestNumber:(NSUInteger)testNumber;

- (void)runnerWillShrinkFailingTestNumber:(NSUInteger)testNumber
                 failedWithPropertyResult:(FOXPropertyResult *)result;
- (void)runnerDidShrinkFailingTestNumber:(NSUInteger)testNumber
                      withPropertyResult:(FOXPropertyResult *)result;
- (void)runnerDidFailTestNumber:(NSUInteger)testNumber
                     withResult:(FOXRunnerResult *)result;

- (void)runnerDidPassNumberOfTests:(NSUInteger)testNumber
                        withResult:(FOXRunnerResult *)result;

- (void)runnerDidRunWithResult:(FOXRunnerResult *)result;

@end

#import <Foundation/Foundation.h>


@class PBTRunnerResult;
@class PBTPropertyResult;


@protocol PBTReporter <NSObject>

- (void)checkerWillRunWithSeed:(uint32_t)randomSeed;

- (void)checkerWillVerifyTestNumber:(NSUInteger)testNumber
                    withMaximumSize:(NSUInteger)maxSize;

- (void)checkerDidPassTestNumber:(NSUInteger)testNumber;

- (void)checkerWillShrinkFailingTestNumber:(NSUInteger)testNumber
                  failedWithPropertyResult:(PBTPropertyResult *)result;
- (void)checkerShrankFailingTestNumber:(NSUInteger)testNumber
                    withPropertyResult:(PBTPropertyResult *)result;
- (void)checkerDidFailTestNumber:(NSUInteger)testNumber
                      withResult:(PBTRunnerResult *)result;

- (void)checkerDidPassNumberOfTests:(NSUInteger)testNumber
                         withResult:(PBTRunnerResult *)result;


@end

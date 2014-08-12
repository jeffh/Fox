#import "PBTDebugReporter.h"
#import "PBTRunnerResult.h"


@implementation PBTDebugReporter {
    FILE *_file;
}

- (instancetype)init
{
    return [self initWithFile:stdout];
}

- (instancetype)initWithFile:(FILE *)file
{
    self = [super init];
    if (self) {
        _file = file;
    }
    return self;
}

- (void)runnerWillRunWithSeed:(uint32_t)randomSeed
{
    [self logString:[NSString stringWithFormat:@"Checking with random seed: %u\n", randomSeed]];
}

- (void)runnerWillVerifyTestNumber:(NSUInteger)testNumber withMaximumSize:(NSUInteger)maxSize
{
    [self logString:[NSString stringWithFormat:@"\n%4.lu. Size=%lu", (unsigned long)testNumber, (unsigned long)maxSize]];
}

- (void)runnerWillShrinkFailingTestNumber:(NSUInteger)testNumber
                 failedWithPropertyResult:(PBTPropertyResult *)result
{
    [self logString:[NSString stringWithFormat:@" [%@] Shrinking", result]];
}

- (void)runnerDidShrinkFailingTestNumber:(NSUInteger)testNumber
                      withPropertyResult:(PBTPropertyResult *)result
{
    [self logString:@"."];
}

- (void)runnerDidPassTestNumber:(NSUInteger)testNumber
{
    [self logString:@" [OK]"];
}

- (void)runnerDidPassNumberOfTests:(NSUInteger)testNumber withResult:(PBTRunnerResult *)result
{
    [self logString:[NSString stringWithFormat:@"\n\n%lu Tests Passed.", testNumber]];
}

- (void)runnerDidFailTestNumber:(NSUInteger)testNumber withResult:(PBTRunnerResult *)result
{
    [self logString:[NSString stringWithFormat:@"\n\n  %@\n", [[result friendlyDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n  "]]];
    [self logString:[NSString stringWithFormat:@")\n\nFailure after %lu tests.\n", testNumber + 1]];
}

- (void)runnerDidRunWithResult:(PBTRunnerResult *)result
{

}

#pragma mark - Private

- (void)logString:(NSString *)message
{
    fprintf(_file, "%s", [message UTF8String]);
    fflush(_file);
}

@end

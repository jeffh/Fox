#import "FOXDebugReporter.h"
#import "FOXRunnerResult.h"


@implementation FOXDebugReporter {
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
                 failedWithPropertyResult:(FOXPropertyResult *)result
{
    [self logString:[NSString stringWithFormat:@" [%@] Shrinking", result]];
}

- (void)runnerDidShrinkFailingTestNumber:(NSUInteger)testNumber
                      withPropertyResult:(FOXPropertyResult *)result
{
    [self logString:@"."];
}

- (void)runnerDidPassTestNumber:(NSUInteger)testNumber
{
    [self logString:@" [OK]"];
}

- (void)runnerDidPassNumberOfTests:(NSUInteger)testNumber withResult:(FOXRunnerResult *)result
{
    [self logString:[NSString stringWithFormat:@"\n\n%lu Tests Passed.", (unsigned long)testNumber]];
}

- (void)runnerDidFailTestNumber:(NSUInteger)testNumber withResult:(FOXRunnerResult *)result
{
    [self logString:[NSString stringWithFormat:@"\n\n  %@\n", [[result friendlyDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n  "]]];
    [self logString:[NSString stringWithFormat:@")\n\nFailure after %lu tests.\n", (unsigned long)(testNumber + 1)]];
}

- (void)runnerDidRunWithResult:(FOXRunnerResult *)result
{

}

#pragma mark - Private

- (void)logString:(NSString *)message
{
    fprintf(_file, "%s", [message UTF8String]);
    fflush(_file);
}

@end

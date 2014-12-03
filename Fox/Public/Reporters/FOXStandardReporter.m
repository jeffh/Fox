#import "FOXStandardReporter.h"
#import "FOXRunnerResult.h"
#import "FOXPropertyResult.h"


@implementation FOXStandardReporter {
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
    [self logString:[NSString stringWithFormat:@"\nChecking with random seed %u\n", randomSeed]];
}

- (void)runnerWillVerifyTestNumber:(NSUInteger)testNumber withMaximumSize:(NSUInteger)maxSize
{
}

- (void)runnerWillShrinkFailingTestNumber:(NSUInteger)testNumber
                 failedWithPropertyResult:(FOXPropertyResult *)result
{
    if (result.status == FOXPropertyStatusUncaughtException) {
        [self logString:@"E"];
    } else {
        [self logString:@"F"];
    }
    [self logString:@"\nShrinking "];
}

- (void)runnerDidShrinkFailingTestNumber:(NSUInteger)testNumber
                      withPropertyResult:(FOXPropertyResult *)result
{
    switch (result.status) {
        case FOXPropertyStatusUncaughtException:
            [self logString:@"E"];
            break;
        case FOXPropertyStatusFailed:
            [self logString:@"F"];
            break;
        case FOXPropertyStatusPassed:
            [self logString:@"."];
            break;
        case FOXPropertyStatusSkipped:
            [self logString:@"S"];
            break;
    }
}

- (void)runnerDidSkipTestNumber:(NSUInteger)testNumber propertyResult:(FOXPropertyResult *)result
{
    [self logString:@"S"];
}

- (void)runnerDidPassTestNumber:(NSUInteger)testNumber propertyResult:(FOXPropertyResult *)result {
    [self logString:@"."];
}

- (void)runnerDidPassNumberOfTests:(NSUInteger)testNumber withResult:(FOXRunnerResult *)result
{
    [self logString:[NSString stringWithFormat:@"\n\n%lu Tests Passed.", (unsigned long)testNumber]];
}

- (void)runnerDidFailTestNumber:(NSUInteger)testNumber withResult:(FOXRunnerResult *)result
{
    [self logString:[NSString stringWithFormat:@"\n\n  %@\n", [[result friendlyDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n  "]]];
    [self logString:[NSString stringWithFormat:@"\n\nFailure after %lu tests.", (unsigned long)(testNumber + 1)]];
}

- (void)runnerDidRunWithResult:(FOXRunnerResult *)result
{
    [self logString:@"\n"];
}

#pragma mark - Private

- (void)logString:(NSString *)message
{
    fprintf(_file, "%s", [message UTF8String]);
    fflush(_file);
}

@end

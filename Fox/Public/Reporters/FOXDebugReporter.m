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

- (void)runnerWillRunWithSeed:(NSUInteger)randomSeed
{
    [self logFormat:@"Checking with random seed: %lu\n", (unsigned long)randomSeed];
}

- (void)runnerWillVerifyTestNumber:(NSUInteger)testNumber withMaximumSize:(NSUInteger)maxSize
{
    [self logFormat:@"\n%4.lu. Size=%lu", (unsigned long)testNumber, (unsigned long)maxSize];
}

- (void)runnerWillShrinkFailingTestNumber:(NSUInteger)testNumber
                 failedWithPropertyResult:(FOXPropertyResult *)result
{
    [self logFormat:@" %@ - Shrinking", result];
}

- (void)runnerDidShrinkFailingTestNumber:(NSUInteger)testNumber
                      withPropertyResult:(FOXPropertyResult *)result
{
    [self logFormat:@"\n      try: %@", result];
}

- (void)runnerDidSkipTestNumber:(NSUInteger)testNumber propertyResult:(FOXPropertyResult *)result
{
    [self logString:@"S"];
}

- (void)runnerDidPassTestNumber:(NSUInteger)testNumber propertyResult:(FOXPropertyResult *)result {
    [self logFormat:@" %@", result];
}

- (void)runnerDidPassNumberOfTests:(NSUInteger)testNumber withResult:(FOXRunnerResult *)result
{
    [self logFormat:@"\n\n%lu Tests Passed.", (unsigned long)testNumber];
}

- (void)runnerDidFailTestNumber:(NSUInteger)testNumber withResult:(FOXRunnerResult *)result
{
    [self logFormat:@"\n\n  %@\n", [[result friendlyDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n  "]];
    [self logFormat:@")\n\nFailure after %lu tests.\n", (unsigned long)(testNumber + 1)];
}

- (void)runnerDidRunWithResult:(FOXRunnerResult *)result
{

}

#pragma mark - Private

- (void)logFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [self logString:[[NSString alloc] initWithFormat:format arguments:args]];
    va_end(args);
}

- (void)logString:(NSString *)message
{
    fprintf(_file, "%s", [message UTF8String]);
    fflush(_file);
}

@end

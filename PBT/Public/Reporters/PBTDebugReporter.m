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

- (void)checkerWillRunWithSeed:(uint32_t)randomSeed
{
    [self logString:[NSString stringWithFormat:@"Checking with random seed: %u\n", randomSeed]];
}

- (void)checkerWillVerifyTestNumber:(NSUInteger)testNumber withMaximumSize:(NSUInteger)maxSize
{
    [self logString:[NSString stringWithFormat:@"\n%4.lu. Size=%lu", (unsigned long)testNumber, (unsigned long)maxSize]];
}

- (void)checkerWillShrinkFailingTestNumber:(NSUInteger)testNumber
                  failedWithPropertyResult:(PBTPropertyResult *)result
{
    [self logString:[NSString stringWithFormat:@" [%@] Shrinking", result]];
}

- (void)checkerShrankFailingTestNumber:(NSUInteger)testNumber
                    withPropertyResult:(PBTPropertyResult *)result
{
    [self logString:@"."];
}

- (void)checkerDidPassTestNumber:(NSUInteger)testNumber
{
    [self logString:@" [OK]"];
}

- (void)checkerDidPassNumberOfTests:(NSUInteger)testNumber withResult:(PBTRunnerResult *)result
{
    [self logString:[NSString stringWithFormat:@"\n\n%lu Tests Passed.", testNumber]];
}

- (void)checkerDidFailTestNumber:(NSUInteger)testNumber withResult:(PBTRunnerResult *)result
{
    [self logString:[NSString stringWithFormat:@"\n\n  %@\n", [[result friendlyDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n  "]]];
    [self logString:[NSString stringWithFormat:@")\n\nFailure after %lu tests.\n", testNumber + 1]];
}

#pragma mark - Private

- (void)logString:(NSString *)message
{
    fprintf(_file, "%s", [message UTF8String]);
    fflush(_file);
}

@end

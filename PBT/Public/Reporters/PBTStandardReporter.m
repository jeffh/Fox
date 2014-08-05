#import "PBTStandardReporter.h"
#import "PBTQuickCheckResult.h"


@implementation PBTStandardReporter {
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
}

- (void)checkerWillShrinkFailingTestNumber:(NSUInteger)testNumber
                  failedWithPropertyResult:(PBTPropertyResult *)result
{
    if (result.status == PBTPropertyStatusUncaughtException) {
        [self logString:@"E"];
    } else {
        [self logString:@"F"];
    }
    [self logString:@" (Shrinking"];
}

- (void)checkerShrankFailingTestNumber:(NSUInteger)testNumber
                    withPropertyResult:(PBTPropertyResult *)result
{
    [self logString:@"."];
}

- (void)checkerDidPassTestNumber:(NSUInteger)testNumber
{
    [self logString:@"."];
}

- (void)checkerDidPassNumberOfTests:(NSUInteger)testNumber withResult:(PBTQuickCheckResult *)result
{
    [self logString:[NSString stringWithFormat:@"\n\n%lu Tests Passed.", testNumber]];
}

- (void)checkerDidFailTestNumber:(NSUInteger)testNumber withResult:(PBTQuickCheckResult *)result
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

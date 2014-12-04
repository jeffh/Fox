#import "FOXRunnerResult.h"

@implementation FOXRunnerResult

- (NSString *)description
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@: ",
                               NSStringFromClass([self class])];
    [string appendString:(self.succeeded ? @"passed" : @"FAILED")];
    [string appendFormat:@"\n seed: %lu", (unsigned long)self.seed];
    [string appendFormat:@"\n maxSize: %lu", (unsigned long)self.maxSize];
    [string appendFormat:@"\n numberOfTests: %lu", (unsigned long)self.numberOfTests];

    if (!self.succeeded) {
        [string appendFormat:@"\n failingSize: %lu", (unsigned long)self.failingSize];
        [string appendFormat:@"\n failingValue: %@", self.failingValue];
        [string appendFormat:@"\n   smallestFailingValue: %@", self.smallestFailingValue];
        [string appendFormat:@"\n   shrinkDepth: %lu", (unsigned long)self.shrinkDepth];
        [string appendFormat:@"\n   shrinkNodeWalkCount: %lu", (unsigned long)self.shrinkNodeWalkCount];
    }

    [string appendString:@">"];

    return string;
}

- (NSString *)friendlyDescription
{
    NSMutableString *string = [NSMutableString stringWithString:@"RESULT: "];
    [string appendString:(self.succeeded ? @"passed" : @"FAILED")];
    [string appendFormat:@"\n seed: %lu", (unsigned long)self.seed];
    [string appendFormat:@"\n maximum size: %lu", (unsigned long)self.maxSize];
    [string appendFormat:@"\n number of tests before failing: %lu", (unsigned long)self.numberOfTests];

    if (!self.succeeded) {
        [string appendFormat:@"\n size that failed: %lu", (unsigned long)self.failingSize];
        [string appendFormat:@"\n shrink depth: %lu", (unsigned long)self.shrinkDepth];
        [string appendFormat:@"\n shrink nodes walked: %lu", (unsigned long)self.shrinkNodeWalkCount];
        [string appendFormat:@"\n value that failed: %@", self.failingValue];
        if (self.failingException) {
            [string appendFormat:@"\n   -> raised %@", self.failingException];
        }
        [string appendFormat:@"\n smallest failing value: %@", self.smallestFailingValue];
        if (self.failingException) {
            [string appendFormat:@"\n   -> raised %@", self.smallestFailingException];
        }
    }
    return string;
}

- (NSString *)singleLineDescriptionOfSmallestValue
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSMutableString *result = [NSMutableString string];
    NSArray *lines = [[self.smallestFailingValue description] componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        [result appendString:[line stringByTrimmingCharactersInSet:whitespace]];
        [result appendString:@" "];
    }
    return result;
}

@end

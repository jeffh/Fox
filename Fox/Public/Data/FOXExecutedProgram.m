#import "FOXExecutedProgram.h"
#import "FOXDictionary.h"
#import "FOXPrettyArray.h"

@implementation FOXExecutedProgram

- (NSString *)description
{
    FOXPrettyArray *serial = [FOXPrettyArray arrayWithArray:self.serialCommands];
    FOXPrettyArray *parallel = [FOXPrettyArray arrayWithArray:self.parallelCommands];
    NSString *succeededString = (self.succeeded ? @"PASSED" : @"FAILED");
    FOXDictionary *result = [FOXDictionary dictionaryWithDictionary:@{@"serial": serial,
                                                                      @"parallel": parallel}];
    return [NSString stringWithFormat:@"<FOXExecutedProgram: %@ %@>",
            succeededString,
            result];
}

@end

#import "FOXProgram.h"
#import "FOXPrettyArray.h"
#import "FOXDictionary.h"

@implementation FOXProgram

- (NSString *)description
{
    FOXPrettyArray *serial = [FOXPrettyArray arrayWithArray:self.serialCommands];
    FOXPrettyArray *parallel = [FOXPrettyArray arrayWithArray:self.parallelCommands];
    FOXDictionary *result = [FOXDictionary dictionaryWithDictionary:@{@"serial": serial,
                                                                      @"parallel": parallel}];
    return [NSString stringWithFormat:@"<FOXProgram: %@>", result];
}

@end

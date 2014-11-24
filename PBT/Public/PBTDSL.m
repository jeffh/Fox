#import "PBTDSL.h"
#import "PBTRunner.h"
#import "PBTRunnerResult.h"


static void _PBTStringReplace(NSMutableString *str, NSString *original, NSString *replacement) {
    [str replaceOccurrencesOfString:original
                         withString:replacement
                            options:0
                              range:NSMakeRange(0, str.length)];
}


PBT_EXPORT PBTRunnerResult *_PBTAssert(id<PBTGenerator> property, NSString *expr, const char *file, int line, PBTOptions options) {
    if (!options.numberOfTests) {
        options.numberOfTests = PBTDefaultNumberOfTests;
    }
    if (!options.maximumSize) {
        options.maximumSize = PBTDefaultMaximumSize;
    }
    if (!options.seed) {
        options.seed = (uint32_t)time(NULL);
    }

    PBTRunner *runner = [PBTRunner sharedInstance];
    PBTRunnerResult *result = [runner resultForNumberOfTests:options.numberOfTests property:property seed:options.seed];
    if (!result.succeeded) {
        NSMutableString *formattedExpression = [NSMutableString stringWithFormat:@"  // %s:%d\n%@;",
                                                file, line, expr];
        _PBTStringReplace(formattedExpression, @"{", @"{\n");
        _PBTStringReplace(formattedExpression, @"}", @"}\n");
        _PBTStringReplace(formattedExpression, @";", @";\n");
        _PBTStringReplace(formattedExpression, @"\n", @"\n  ");
        [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]
                                                                file:[NSString stringWithUTF8String:file] \
                                                          lineNumber:line
                                                         description:
         @"=== Property failed ===\n"
         @"%@\n"
         @"%@",
         formattedExpression,
         [result friendlyDescription]];
    }
    return result;
}

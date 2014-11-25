#import "FOXDSL.h"
#import "FOXRunner.h"
#import "FOXRunnerResult.h"


static void _FOXStringReplace(NSMutableString *str, NSString *original, NSString *replacement) {
    [str replaceOccurrencesOfString:original
                         withString:replacement
                            options:0
                              range:NSMakeRange(0, str.length)];
}


FOX_EXPORT FOXRunnerResult *_FOXAssert(id<FOXGenerator> property, NSString *expr, const char *file, int line, FOXOptions options) {
    if (!options.numberOfTests) {
        options.numberOfTests = FOXDefaultNumberOfTests;
    }
    if (!options.maximumSize) {
        options.maximumSize = FOXDefaultMaximumSize;
    }
    if (!options.seed) {
        options.seed = (uint32_t)time(NULL);
    }

    FOXRunner *runner = [FOXRunner sharedInstance];
    FOXRunnerResult *result = [runner resultForNumberOfTests:options.numberOfTests property:property seed:options.seed];
    if (!result.succeeded) {
        NSMutableString *formattedExpression = [NSMutableString stringWithFormat:@"  // %s:%d\n%@;",
                                                file, line, expr];
        _FOXStringReplace(formattedExpression, @"{", @"{\n");
        _FOXStringReplace(formattedExpression, @"}", @"}\n");
        _FOXStringReplace(formattedExpression, @";", @";\n");
        _FOXStringReplace(formattedExpression, @"\n", @"\n  ");
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

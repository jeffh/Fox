#import "FOXDSL.h"
#import "FOXRunner.h"
#import "FOXRunnerResult.h"
#import "FOXEnvironment.h"

static void _FOXStringReplace(NSMutableString *str, NSString *original, NSString *replacement) {
    [str replaceOccurrencesOfString:original
                         withString:replacement
                            options:0
                              range:NSMakeRange(0, str.length)];
}


FOX_EXPORT FOXRunnerResult *_FOXAssert(id<FOXGenerator> property, NSString *expr, const char *file, unsigned int line, FOXOptions options) {
    if (!options.numberOfTests) {
        options.numberOfTests = FOXGetNumberOfTests();
    }
    if (!options.maximumSize) {
        options.maximumSize = FOXGetMaximumSize();
    }
    if (!options.seed) {
        options.seed = FOXGetSeed();
    }

    FOXRunner *runner = [FOXRunner assertInstance];
    FOXRunnerResult *result = [runner resultForNumberOfTests:options.numberOfTests property:property seed:options.seed];
    if (!result.succeeded) {
        NSMutableString *formattedExpression = [NSMutableString stringWithFormat:@"  // %s:%d\n%@;",
                                                file, line, expr ?: @""];
        _FOXStringReplace(formattedExpression, @"{", @"{\n");
        _FOXStringReplace(formattedExpression, @"}", @"}\n");
        _FOXStringReplace(formattedExpression, @";", @";\n");
        _FOXStringReplace(formattedExpression, @"\n", @"\n  ");
        NSString *description = [NSString stringWithFormat:
                                 @"Property failed with: %@\n"
                                 @"Location: %@\n"
                                 @"%@",
                                 [result singleLineDescriptionOfSmallestValue],
                                 formattedExpression,
                                 [result friendlyDescription]];

        [NSException raise:@"FOXAssertionFailure" format:@"%@", description];
    }
    return result;
}

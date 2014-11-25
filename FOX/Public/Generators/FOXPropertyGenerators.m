#import "FOXPropertyGenerators.h"
#import "FOXCoreGenerators.h"


FOX_EXPORT id<FOXGenerator> FOXForAll(id<FOXGenerator> generator, BOOL (^then)(id generatedValue)) {
    return FOXWithName(@"FOXForAll", FOXForSome(generator, ^FOXPropertyStatus(id generatedValue) {
        return FOXRequire(then(generatedValue));
    }));
}

FOX_EXPORT id<FOXGenerator> FOXForSome(id<FOXGenerator> generator, FOXPropertyStatus (^verifier)(id generatedValue)) {
    return FOXWithName(@"FOXForSome", FOXMap(generator, ^id(id value) {
        FOXPropertyResult *result = [[FOXPropertyResult alloc] init];
        result.generatedValue = value;
        @try {
            result.status = verifier(value);
        }
        @catch (NSException *exception) {
            result.uncaughtException = exception;
            result.status = FOXPropertyStatusUncaughtException;
        }
        return result;
    }));
}

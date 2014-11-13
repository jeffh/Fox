#import "PBTPropertyGenerators.h"
#import "PBTCoreGenerators.h"


PBT_EXPORT id<PBTGenerator> PBTForAll(id<PBTGenerator> generator, PBTPropertyStatus (^verifier)(id generatedValue)) {
    return PBTMap(generator, ^id(id value) {
        PBTPropertyResult *result = [[PBTPropertyResult alloc] init];
        result.generatedValue = value;
        @try {
            result.status = verifier(value);
        }
        @catch (NSException *exception) {
            result.uncaughtException = exception;
            result.status = PBTPropertyStatusUncaughtException;
        }
        return result;
    });
}

PBT_EXPORT id<PBTGenerator> PBTForAll(id<PBTGenerator> generator, BOOL (^then)(id generatedValue)) {
    return PBTForAll(generator, ^PBTPropertyStatus(id generatedValue) {
        return PBTRequire(then(generatedValue));
    });
}

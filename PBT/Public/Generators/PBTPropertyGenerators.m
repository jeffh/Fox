#import "PBTPropertyGenerators.h"
#import "PBTCoreGenerators.h"


PBT_EXPORT id<PBTGenerator> PBTForAll(id<PBTGenerator> generator, BOOL (^then)(id generatedValue)) {
    return PBTWithName(@"PBTForAll", PBTForSome(generator, ^PBTPropertyStatus(id generatedValue) {
        return PBTRequire(then(generatedValue));
    }));
}

PBT_EXPORT id<PBTGenerator> PBTForSome(id<PBTGenerator> generator, PBTPropertyStatus (^verifier)(id generatedValue)) {
    return PBTWithName(@"PBTForSome", PBTMap(generator, ^id(id value) {
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
    }));
}

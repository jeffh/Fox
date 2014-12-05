#import "FOXEnvironment.h"


const NSUInteger FOXDefaultNumberOfTests = 500;
const NSUInteger FOXDefaultMaximumSize = 200;

static NSUInteger FOXGetUIntegerFromEnv(const char *envname, NSUInteger defaultValue) {
    const char *envval = getenv(envname);
    if (envval == NULL) {
        envval = "";
    }
    NSUInteger number = defaultValue;
    sscanf(envval, "%lu", &number);
    return number;
}

FOX_EXPORT NSUInteger FOXGetNumberOfTests(void) {
    return FOXGetUIntegerFromEnv("FOX_NUM_TESTS", FOXDefaultNumberOfTests);
}

FOX_EXPORT NSUInteger FOXGetMaximumSize(void) {
    return FOXGetUIntegerFromEnv("FOX_MAX_SIZE", FOXDefaultMaximumSize);
}

FOX_EXPORT NSUInteger FOXGetSeed(void) {
    return FOXGetUIntegerFromEnv("FOX_SEED", (NSUInteger)time(NULL));
}

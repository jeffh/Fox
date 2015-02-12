#import "FOXEnvironment.h"

const NSUInteger FOXDefaultNumberOfTests = 500;
const NSUInteger FOXDefaultMaximumSize = 200;

static NSUInteger __FOXNumberOfTests = FOXDefaultNumberOfTests;
static NSUInteger __FOXMaximumSize = FOXDefaultMaximumSize;
static NSUInteger __FOXSeed = 0;

static NSUInteger FOXGetUIntegerFromEnv(const char *envname, NSUInteger defaultValue) {
    const char *envval = getenv(envname);
    unsigned long number = defaultValue;
    if (envval != NULL) {
        sscanf(envval, "%lu", &number);
    }
    return (NSUInteger)number;
}

static NSUInteger FOXEnsureNonZero(NSUInteger value, NSUInteger defaultValue) {
    if (value == 0) {
        return defaultValue;
    } else {
        return value;
    }
}

NSUInteger FOXGetNumberOfTests(void) {
    return FOXEnsureNonZero(FOXGetUIntegerFromEnv("FOX_NUM_TESTS", __FOXNumberOfTests),
                            FOXDefaultNumberOfTests);
}

NSUInteger FOXGetMaximumSize(void) {
    return FOXEnsureNonZero(FOXGetUIntegerFromEnv("FOX_MAX_SIZE", __FOXMaximumSize),
                            FOXDefaultNumberOfTests);
}

NSUInteger FOXGetSeed(void) {
    if (!__FOXSeed) {
        __FOXSeed = (NSUInteger)time(NULL);
    }
    return FOXGetUIntegerFromEnv("FOX_SEED", __FOXSeed);
}

void FOXSetNumberOfTests(NSUInteger defaultNumberOfTests) {
    __FOXNumberOfTests = defaultNumberOfTests;
}

void FOXSetMaximumSize(NSUInteger defaultMaximumSize) {
    __FOXMaximumSize = defaultMaximumSize;
}

void FOXSetSeed(NSUInteger defaultRandomSeed) {
    if (defaultRandomSeed == 0) {
        defaultRandomSeed = (NSUInteger)time(NULL);
    }
    __FOXSeed = defaultRandomSeed;
}

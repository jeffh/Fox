#import "FOXEnvironment.h"


const NSUInteger FOXDefaultNumberOfTests = 500;
const NSUInteger FOXDefaultMaximumSize = 200;

static NSUInteger FOXGetUIntegerFromEnv(const char *envname, NSUInteger defaultValue) {
    const char *envval = getenv("FOX_NUM_TESTS");
    if (envval == NULL) {
        envval = "";
    }
    NSString *value = [NSString stringWithCString:envval
                                         encoding:NSUTF8StringEncoding];
    if ([value integerValue] > 0) {
        return [value integerValue];
    }
    return defaultValue;
}

FOX_EXPORT NSUInteger FOXGetNumberOfTests(void) {
    return FOXGetUIntegerFromEnv("FOX_NUM_TESTS", FOXDefaultNumberOfTests);
}

FOX_EXPORT NSUInteger FOXGetMaximumSize(void) {
    return FOXGetUIntegerFromEnv("FOX_MAX_SIZE", FOXDefaultMaximumSize);
}

FOX_EXPORT uint32_t FOXGetSeed(void) {
    return (uint32_t)FOXGetUIntegerFromEnv("FOX_SEED", (uint32_t)time(NULL));
}

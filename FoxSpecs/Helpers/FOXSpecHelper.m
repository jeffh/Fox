#import "FOXSpecHelper.h"
#import "FOX.h"
#import "FOXDebugReporter.h"

@implementation FOXSpecHelper

const NSUInteger defaultNumberOfTests = 500;
static NSUInteger ___numberOfTests;

+ (void)initialize
{
    const char *envval = getenv("FOX_SPECS_NUM_TESTS");
    NSUInteger numberOfTests = defaultNumberOfTests;
    if (envval) {
        sscanf(envval, "%lu", &numberOfTests);
    }
    printf("Fox Seed: %lu\n", numberOfTests);
    ___numberOfTests = numberOfTests;
}

+ (NSUInteger)numberOfTestsPerProperty
{
    return ___numberOfTests;
}

+ (FOXRunnerResult *)resultForAll:(id<FOXGenerator>)generator
                             then:(BOOL(^)(id value))block {
    id<FOXGenerator> property = FOXForSome(generator, ^FOXPropertyStatus(id value) {
        return FOXRequire(block(value));
    });
    FOXRunner *quick = [[FOXRunner alloc] initWithReporter:nil];
    return [quick resultForNumberOfTests:[self numberOfTestsPerProperty] property:property];
}

+ (FOXRunnerResult *)debug_resultForAll:(id<FOXGenerator>)generator
                                   then:(BOOL(^)(id value))block {
    id<FOXGenerator> property = FOXForSome(generator, ^FOXPropertyStatus(id value) {
        return FOXRequire(block(value));
    });
    FOXRunner *quick = [[FOXRunner alloc] initWithReporter:[[FOXDebugReporter alloc] init]];
    return [quick resultForNumberOfTests:[self numberOfTestsPerProperty] property:property];
}

+ (FOXRunnerResult *)resultForAll:(id<FOXGenerator>)generator
                             then:(BOOL(^)(id value))block
                             seed:(uint32_t)seed {
    return [self resultForAll:generator then:block seed:seed maxSize:50];
}

+ (FOXRunnerResult *)resultForAll:(id<FOXGenerator>)generator
                             then:(BOOL(^)(id value))block
                             seed:(uint32_t)seed
                          maxSize:(NSUInteger)maxSize {
    id<FOXGenerator> property = FOXForSome(generator, ^FOXPropertyStatus(id value) {
        return FOXRequire(block(value));
    });
    FOXRunner *quick = [[FOXRunner alloc] initWithReporter:[[FOXDebugReporter alloc] init]];
    return [quick resultForNumberOfTests:[self numberOfTestsPerProperty]
                                property:property
                                    seed:seed
                                 maxSize:maxSize];
}

+ (FOXRunnerResult *)shrunkResultForAll:(id<FOXGenerator>)generator
{
    __block NSInteger timesUntilFailure = 10;
    return [self resultForAll:generator then:^BOOL(id value) {
        if (timesUntilFailure == 0) {
            return NO;
        } else {
            timesUntilFailure--;
        }
        return YES;
    }];
}

+ (FOXRunnerResult *)debug_shrunkResultForAll:(id<FOXGenerator>)generator
{
    __block NSInteger timesUntilFailure = 10;
    return [self debug_resultForAll:generator then:^BOOL(id value) {
        if (timesUntilFailure == 0) {
            return NO;
        } else {
            timesUntilFailure--;
        }
        return YES;
    }];
}

@end

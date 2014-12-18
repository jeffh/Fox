#import "FOXSpecHelper.h"
#import "FOX.h"
#import "FOXDebugReporter.h"

@implementation FOXSpecHelper

+ (NSUInteger)numberOfTestsPerProperty
{
    return FOXGetNumberOfTests();
}

+ (void)initialize
{
    printf("FOX_NUM_TESTS=%lu, FOX_SEED=%lu, FOX_MAX_SIZE=%lu\n", FOXGetNumberOfTests(), FOXGetSeed(), FOXGetMaximumSize());
}

+ (FOXRunnerResult *)resultForProperty:(id<FOXGenerator>)propertyGenerator
{
    FOXRunner *quick = [[FOXRunner alloc] initWithReporter:nil];
    return [quick resultForNumberOfTests:[self numberOfTestsPerProperty] property:propertyGenerator];
}

+ (FOXRunnerResult *)resultForProperty:(id<FOXGenerator>)propertyGenerator numberOfTests:(NSUInteger)numberOfTests
{
    FOXRunner *quick = [[FOXRunner alloc] initWithReporter:nil];
    return [quick resultForNumberOfTests:numberOfTests property:propertyGenerator];
}

+ (FOXRunnerResult *)resultForAll:(id<FOXGenerator>)generator
                             then:(BOOL(^)(id value))block
{
    id<FOXGenerator> property = FOXForSome(generator, ^FOXPropertyStatus(id value) {
        return FOXRequire(block(value));
    });
    FOXRunner *quick = [[FOXRunner alloc] initWithReporter:nil];
    return [quick resultForNumberOfTests:[self numberOfTestsPerProperty] property:property];
}

+ (FOXRunnerResult *)resultForAll:(id<FOXGenerator>)generator
                             then:(BOOL(^)(id value))block
                    numberOfTests:(NSUInteger)numberOfTests
{
    id<FOXGenerator> property = FOXForSome(generator, ^FOXPropertyStatus(id value) {
        return FOXRequire(block(value));
    });
    FOXRunner *quick = [[FOXRunner alloc] initWithReporter:nil];
    return [quick resultForNumberOfTests:numberOfTests property:property];
}

+ (FOXRunnerResult *)debug_resultForAll:(id<FOXGenerator>)generator
                                   then:(BOOL(^)(id value))block
{
    id<FOXGenerator> property = FOXForSome(generator, ^FOXPropertyStatus(id value) {
        return FOXRequire(block(value));
    });
    FOXRunner *quick = [[FOXRunner alloc] initWithReporter:[[FOXDebugReporter alloc] init]];
    return [quick resultForNumberOfTests:[self numberOfTestsPerProperty] property:property];
}

+ (FOXRunnerResult *)resultForAll:(id<FOXGenerator>)generator
                             then:(BOOL(^)(id value))block
                             seed:(uint32_t)seed
{
    return [self resultForAll:generator then:block seed:seed maxSize:50];
}

+ (FOXRunnerResult *)resultForAll:(id<FOXGenerator>)generator
                             then:(BOOL(^)(id value))block
                             seed:(uint32_t)seed
                          maxSize:(NSUInteger)maxSize
{
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

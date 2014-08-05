#import "PBTSpecHelper.h"
#import "PBTDebugReporter.h"

@implementation PBTSpecHelper

+ (NSUInteger)numberOfTestsPerProperty
{
    return 100;
}

+ (PBTQuickCheckResult *)resultForAll:(id<PBTGenerator>)generator
                                 then:(BOOL(^)(id value))block {
    id<PBTGenerator> property = [PBTProperty forAll:generator then:^PBTPropertyStatus(id value){
        return PBTRequire(block(value));
    }];
    PBTQuickCheck *quick = [[PBTQuickCheck alloc] initWithReporter:nil];
    return [quick checkWithNumberOfTests:[self numberOfTestsPerProperty] property:property];
}

+ (PBTQuickCheckResult *)debug_resultForAll:(id<PBTGenerator>)generator
                                       then:(BOOL(^)(id value))block {
    id<PBTGenerator> property = [PBTProperty forAll:generator then:^PBTPropertyStatus(id value){
        return PBTRequire(block(value));
    }];
    PBTQuickCheck *quick = [[PBTQuickCheck alloc] initWithReporter:[[PBTDebugReporter alloc] init]];
    return [quick checkWithNumberOfTests:[self numberOfTestsPerProperty] property:property];
}

+ (PBTQuickCheckResult *)resultForAll:(id<PBTGenerator>)generator
                                 then:(BOOL(^)(id value))block
                                 seed:(uint32_t)seed {
    return [self resultForAll:generator then:block seed:seed maxSize:50];
}

+ (PBTQuickCheckResult *)resultForAll:(id<PBTGenerator>)generator
                                 then:(BOOL(^)(id value))block
                                 seed:(uint32_t)seed
                              maxSize:(NSUInteger)maxSize {
    id<PBTGenerator> property = [PBTProperty forAll:generator then:^PBTPropertyStatus(id value){
        return PBTRequire(block(value));
    }];
    PBTQuickCheck *quick = [[PBTQuickCheck alloc] initWithReporter:[[PBTDebugReporter alloc] init]];
    return [quick checkWithNumberOfTests:[self numberOfTestsPerProperty]
                                property:property
                                    seed:seed
                                 maxSize:maxSize];
}

+ (PBTQuickCheckResult *)shrunkResultForAll:(id<PBTGenerator>)generator
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

+ (PBTQuickCheckResult *)debug_shrunkResultForAll:(id<PBTGenerator>)generator
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

#import "PBTSpecHelper.h"
#import "PBT.h"
#import "PBTDebugReporter.h"

@implementation PBTSpecHelper

+ (NSUInteger)numberOfTestsPerProperty
{
    return 100;
}

+ (PBTRunnerResult *)resultForAll:(id<PBTGenerator>)generator
                                 then:(BOOL(^)(id value))block {
    id<PBTGenerator> property = [PBTProperty forAll:generator then:^PBTPropertyStatus(id value){
        return PBTRequire(block(value));
    }];
    PBTRunner *quick = [[PBTRunner alloc] initWithReporter:nil];
    return [quick resultForNumberOfTests:[self numberOfTestsPerProperty] property:property];
}

+ (PBTRunnerResult *)debug_resultForAll:(id<PBTGenerator>)generator
                                       then:(BOOL(^)(id value))block {
    id<PBTGenerator> property = [PBTProperty forAll:generator then:^PBTPropertyStatus(id value){
        return PBTRequire(block(value));
    }];
    PBTRunner *quick = [[PBTRunner alloc] initWithReporter:[[PBTDebugReporter alloc] init]];
    return [quick resultForNumberOfTests:[self numberOfTestsPerProperty] property:property];
}

+ (PBTRunnerResult *)resultForAll:(id<PBTGenerator>)generator
                                 then:(BOOL(^)(id value))block
                                 seed:(uint32_t)seed {
    return [self resultForAll:generator then:block seed:seed maxSize:50];
}

+ (PBTRunnerResult *)resultForAll:(id<PBTGenerator>)generator
                                 then:(BOOL(^)(id value))block
                                 seed:(uint32_t)seed
                              maxSize:(NSUInteger)maxSize {
    id<PBTGenerator> property = [PBTProperty forAll:generator then:^PBTPropertyStatus(id value){
        return PBTRequire(block(value));
    }];
    PBTRunner *quick = [[PBTRunner alloc] initWithReporter:[[PBTDebugReporter alloc] init]];
    return [quick resultForNumberOfTests:[self numberOfTestsPerProperty]
                                property:property
                                    seed:seed
                                 maxSize:maxSize];
}

+ (PBTRunnerResult *)shrunkResultForAll:(id<PBTGenerator>)generator
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

+ (PBTRunnerResult *)debug_shrunkResultForAll:(id<PBTGenerator>)generator
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

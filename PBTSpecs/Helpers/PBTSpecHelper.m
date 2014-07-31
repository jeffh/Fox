#import "PBTSpecHelper.h"

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
    PBTQuickCheck *quick = [[PBTQuickCheck alloc] init];
    return [quick checkWithNumberOfTests:[self numberOfTestsPerProperty] property:property];
}

@end

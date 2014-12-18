#import "FOX.h"

@interface FOXSpecHelper : NSObject

+ (NSUInteger)numberOfTestsPerProperty;
+ (FOXRunnerResult *)resultForProperty:(id<FOXGenerator>)propertyGenerator;
+ (FOXRunnerResult *)resultForProperty:(id<FOXGenerator>)propertyGenerator
                         numberOfTests:(NSUInteger)numberOfTests;
+ (FOXRunnerResult *)resultForAll:(id<FOXGenerator>)generator
                             then:(BOOL(^)(id value))block;
+ (FOXRunnerResult *)resultForAll:(id<FOXGenerator>)generator
                             then:(BOOL(^)(id value))block
                    numberOfTests:(NSUInteger)numberOfTests;
+ (FOXRunnerResult *)debug_resultForAll:(id<FOXGenerator>)generator
                                   then:(BOOL(^)(id value))block;
+ (FOXRunnerResult *)resultForAll:(id<FOXGenerator>)generator
                             then:(BOOL(^)(id value))block
                             seed:(uint32_t)seed;
+ (FOXRunnerResult *)shrunkResultForAll:(id<FOXGenerator>)generator;
+ (FOXRunnerResult *)debug_shrunkResultForAll:(id<FOXGenerator>)generator;

@end

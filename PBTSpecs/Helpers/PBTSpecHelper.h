#import "PBT.h"

@interface PBTSpecHelper : NSObject

+ (NSUInteger)numberOfTestsPerProperty;
+ (PBTRunnerResult *)resultForAll:(id<PBTGenerator>)generator
                                 then:(BOOL(^)(id value))block;
+ (PBTRunnerResult *)debug_resultForAll:(id<PBTGenerator>)generator
                                       then:(BOOL(^)(id value))block;
+ (PBTRunnerResult *)resultForAll:(id<PBTGenerator>)generator
                                 then:(BOOL(^)(id value))block
                                 seed:(uint32_t)seed;
+ (PBTRunnerResult *)shrunkResultForAll:(id<PBTGenerator>)generator;
+ (PBTRunnerResult *)debug_shrunkResultForAll:(id<PBTGenerator>)generator;

@end

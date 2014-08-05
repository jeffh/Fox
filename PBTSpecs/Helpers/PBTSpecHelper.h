#import "PBT.h"

@interface PBTSpecHelper : NSObject

+ (NSUInteger)numberOfTestsPerProperty;
+ (PBTQuickCheckResult *)resultForAll:(id<PBTGenerator>)generator
                                 then:(BOOL(^)(id value))block;
+ (PBTQuickCheckResult *)debug_resultForAll:(id<PBTGenerator>)generator
                                       then:(BOOL(^)(id value))block;
+ (PBTQuickCheckResult *)resultForAll:(id<PBTGenerator>)generator
                                 then:(BOOL(^)(id value))block
                                 seed:(uint32_t)seed;
+ (PBTQuickCheckResult *)shrunkResultForAll:(id<PBTGenerator>)generator;
+ (PBTQuickCheckResult *)debug_shrunkResultForAll:(id<PBTGenerator>)generator;

@end

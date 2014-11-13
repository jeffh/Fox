#import "PBTMacros.h"

@protocol PBTGenerator;

typedef struct {
    uint32_t   seed;          // 0 = random seed
    NSUInteger numberOfTests; // 0 = 500 tests
} PBTAssertOptions;

PBT_EXPORT void PBTAssert(id<PBTGenerator> property);
PBT_EXPORT void PBTAssert(id<PBTGenerator> property, PBTAssertOptions options);

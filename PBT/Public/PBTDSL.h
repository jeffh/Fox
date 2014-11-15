#import "PBTMacros.h"

@protocol PBTGenerator;
@class PBTRunnerResult;

typedef struct {
    uint32_t   seed;          // 0 = random seed
    NSUInteger numberOfTests; // 0 = 500 tests
} PBTOptions;

PBT_EXPORT PBTRunnerResult *_PBTAssert(id<PBTGenerator> property, NSString *expr, const char * file, int line, PBTOptions options);

#define PBTAssertWithOptions(PROPERTY, OPTIONS) (_PBTAssert((PROPERTY), @"" # PROPERTY, __FILE__, __LINE__, (OPTIONS)))

#define PBTAssert(PROPERTY) (PBTAssertWithOptions(PROPERTY, (PBTOptions){}))

#if !defined(PBT_DISABLE_SHORTHAND) && !defined(PBT_DISABLE_SHORTHAND_ASSERT)
    #define Assert PBTAssert
    #define AssertWithOptions PBTAssertWithOptions
#endif

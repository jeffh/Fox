#import "PBTDSL.h"
#import "PBTRunner.h"
#import "PBTRunnerResult.h"


PBT_EXPORT void PBTAssert(id<PBTGenerator> property) {
    return PBTAssert(property, (PBTAssertOptions){});
}

PBT_EXPORT void PBTAssert(id<PBTGenerator> property, PBTAssertOptions options) {
    if (!options.numberOfTests) {
        options.numberOfTests = 500;
    }
    if (!options.seed) {
        options.seed = (uint32_t)time(NULL);
    }

    PBTRunner *runner = [PBTRunner sharedInstance];
    PBTRunnerResult *result = [runner resultForNumberOfTests:options.numberOfTests property:property seed:options.seed];
    NSCAssert(result.succeeded,
              @"Failed pass property %@:\n%@",
              property, [result friendlyDescription]);
}

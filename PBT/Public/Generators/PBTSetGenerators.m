#import "PBTSetGenerators.h"
#import "PBTCoreGenerators.h"
#import "PBTArrayGenerators.h"


PBT_EXPORT id<PBTGenerator> PBTSet(id<PBTGenerator> elementGenerator) {
    return PBTMap(PBTArray(elementGenerator), ^id(NSArray *elements) {
        return [NSMutableSet setWithArray:elements];
    });
}

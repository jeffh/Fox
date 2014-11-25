#import "FOXSetGenerators.h"
#import "FOXCoreGenerators.h"
#import "FOXArrayGenerators.h"


FOX_EXPORT id<FOXGenerator> FOXSet(id<FOXGenerator> elementGenerator) {
    return FOXMap(FOXArray(elementGenerator), ^id(NSArray *elements) {
        return [NSMutableSet setWithArray:elements];
    });
}

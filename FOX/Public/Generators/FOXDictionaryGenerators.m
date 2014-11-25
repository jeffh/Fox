#import "FOXDictionaryGenerators.h"
#import "FOXCoreGenerators.h"
#import "FOXArrayGenerators.h"


FOX_EXPORT id<FOXGenerator> FOXDictionary(NSDictionary *dictionaryTemplate) {
    return FOXMap(FOXTuple([dictionaryTemplate allValues]), ^id(NSArray *values) {
        return [NSDictionary dictionaryWithObjects:values forKeys:[dictionaryTemplate allKeys]];
    });
}

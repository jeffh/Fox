#import "PBTDictionaryGenerators.h"
#import "PBTCoreGenerators.h"
#import "PBTArrayGenerators.h"


PBT_EXPORT id<PBTGenerator> PBTDictionary(NSDictionary *dictionaryTemplate) {
    return PBTMap(PBTTuple([dictionaryTemplate allValues]), ^id(NSArray *values) {
        return [NSDictionary dictionaryWithObjects:values forKeys:[dictionaryTemplate allKeys]];
    });
}

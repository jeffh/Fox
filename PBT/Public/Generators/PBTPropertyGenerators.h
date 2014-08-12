#import "PBTMacros.h"
#import "PBTPropertyResult.h"


@protocol PBTGenerator;


PBT_EXPORT id<PBTGenerator> PBTForAll(id<PBTGenerator> generator, PBTPropertyStatus (^then)(id generatedValue));



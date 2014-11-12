#import "PBTMacros.h"

@protocol PBTGenerator;

PBT_EXPORT id<PBTGenerator> PBTSimpleType(void);
PBT_EXPORT id<PBTGenerator> PBTCompositeType(id<PBTGenerator> itemGenerator);
PBT_EXPORT id<PBTGenerator> PBTAnyObject(void);

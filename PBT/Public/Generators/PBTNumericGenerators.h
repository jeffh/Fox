#import "PBTMacros.h"


@protocol PBTGenerator;


PBT_EXPORT id<PBTGenerator> PBTPositiveInteger(void);

PBT_EXPORT id<PBTGenerator> PBTNegativeInteger(void);

PBT_EXPORT id<PBTGenerator> PBTStrictPositiveInteger(void);

PBT_EXPORT id<PBTGenerator> PBTStrictNegativeInteger(void);

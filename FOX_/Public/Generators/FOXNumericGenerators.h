#import "FOXMacros.h"


@protocol FOXGenerator;

FOX_EXPORT id<FOXGenerator> FOXBoolean(void);

FOX_EXPORT id<FOXGenerator> FOXPositiveInteger(void);

FOX_EXPORT id<FOXGenerator> FOXNegativeInteger(void);

FOX_EXPORT id<FOXGenerator> FOXStrictPositiveInteger(void);

FOX_EXPORT id<FOXGenerator> FOXStrictNegativeInteger(void);

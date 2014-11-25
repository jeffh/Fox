#import "FOXMacros.h"

@protocol FOXGenerator;

FOX_EXPORT id<FOXGenerator> FOXSimpleType(void);
FOX_EXPORT id<FOXGenerator> FOXPrintableSimpleType(void);
FOX_EXPORT id<FOXGenerator> FOXCompositeType(id<FOXGenerator> itemGenerator);
FOX_EXPORT id<FOXGenerator> FOXAnyObject(void);

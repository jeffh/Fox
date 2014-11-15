#import "PBTMacros.h"
#import "PBTPropertyResult.h"


@protocol PBTGenerator;


PBT_EXPORT id<PBTGenerator> PBTForAll(id<PBTGenerator> generator, BOOL (^then)(id generatedValue));
PBT_EXPORT id<PBTGenerator> PBTForAll(id<PBTGenerator> generator, PBTPropertyStatus (^then)(id generatedValue));

#if !defined(PBT_DISABLE_SHORTHAND)
PBT_INLINE id<PBTGenerator> forAll(id<PBTGenerator> generator, BOOL (^then)(id generatedValue)) {
    return PBTForAll(generator, then);
}

PBT_INLINE id<PBTGenerator> forAll(id<PBTGenerator> generator, PBTPropertyStatus (^then)(id generatedValue)) {
    return PBTForAll(generator, then);
}
#endif

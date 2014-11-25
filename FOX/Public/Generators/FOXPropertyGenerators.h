#import "FOXMacros.h"
#import "FOXPropertyResult.h"


@protocol FOXGenerator;


FOX_EXPORT id<FOXGenerator> FOXForAll(id<FOXGenerator> generator, BOOL (^then)(id generatedValue));
FOX_EXPORT id<FOXGenerator> FOXForSome(id<FOXGenerator> generator, FOXPropertyStatus (^then)(id generatedValue));

#if !defined(FOX_DISABLE_SHORTHAND)
FOX_INLINE id<FOXGenerator> forAll(id<FOXGenerator> generator, BOOL (^then)(id generatedValue)) {
    return FOXForAll(generator, then);
}

FOX_INLINE id<FOXGenerator> forSome(id<FOXGenerator> generator, FOXPropertyStatus (^then)(id generatedValue)) {
    return FOXForSome(generator, then);
}
#endif

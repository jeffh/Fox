#import "PBTProperty.h"
#import "PBTGenerator.h"


@implementation PBTProperty

+ (id)forAll:(PBTGenerator)generator
        then:(PBTPropertyResult (^)(id))verifier
{
    return PBTGenMap(generator, ^id(id generatedValue) {
        return @(verifier(generatedValue));
    });
}

@end


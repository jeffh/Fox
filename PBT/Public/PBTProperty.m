#import "PBTProperty.h"
#import "PBTGenerator.h"


@implementation PBTProperty

+ (id)forAll:(PBTGenerator)generator
        then:(PBTPropertyResult (^)(id))verifier
{
    return PBTMap(generator, ^id(id roseTree) {
        return @(verifier([roseTree firstObject]));
    });
}

@end


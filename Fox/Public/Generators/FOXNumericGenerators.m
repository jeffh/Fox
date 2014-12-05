#import "FOXNumericGenerators.h"
#import "FOXCoreGenerators.h"
#import "FOXGenerator.h"
#import "FOXArrayGenerators.h"
#import "FOXRoseTree.h"


FOX_EXPORT id<FOXGenerator> _FOXNaturalInteger(void) {
    return FOXMap(FOXInteger(), ^id(NSNumber *number) {
        return @(ABS([number integerValue]));
    });
}

FOX_EXPORT id<FOXGenerator> FOXBoolean(void) {
    return FOXWithName(@"FOXBoolean", FOXChoose(@0, @1));
}

FOX_EXPORT id<FOXGenerator> FOXPositiveInteger(void) {
    return FOXWithName(@"PositiveInteger", _FOXNaturalInteger());
}

FOX_EXPORT id<FOXGenerator> FOXNegativeInteger(void) {
    return FOXWithName(@"NegativeInteger", FOXMap(_FOXNaturalInteger(), ^id(NSNumber *number) {
        return @(-[number integerValue]);
    }));
}

FOX_EXPORT id<FOXGenerator> FOXStrictPositiveInteger(void) {
    return FOXWithName(@"StrictPostiveInteger", FOXMap(_FOXNaturalInteger(), ^id(NSNumber *number) {
        return @([number integerValue] ?: 1);
    }));
}

FOX_EXPORT id<FOXGenerator> FOXStrictNegativeInteger(void) {
    return FOXWithName(@"StrictNegativeInteger", FOXMap(_FOXNaturalInteger(), ^id(NSNumber *number) {
        return @(-([number integerValue] ?: 1));
    }));
}

FOX_EXPORT id<FOXGenerator> FOXNonZeroInteger(void) {
    return FOXWithName(@"NonZeroInteger", FOXMap(FOXInteger(), ^id(NSNumber *number) {
        return @([number integerValue] ?: 1);
    }));
}

FOX_EXPORT id<FOXGenerator> FOXFloat(void) {
    return FOXSized(^id<FOXGenerator>(NSUInteger size) {
        return FOXBind(FOXChoose(@1, @(MAX(size, 1))), ^id<FOXGenerator>(NSNumber *divisor) {
            return FOXBind(FOXChoose(@(-size), @(size)), ^id<FOXGenerator>(NSNumber *dividend) {
                return FOXReturn(@([dividend floatValue] / [divisor floatValue]));
            });
        });
    });
}

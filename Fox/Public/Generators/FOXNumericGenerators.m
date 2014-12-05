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
    return FOXGenMap(FOXDecimalNumber(), ^FOXRoseTree *(FOXRoseTree *generatedTree) {
        return [generatedTree treeByApplyingBlock:^id(NSDecimalNumber *element) {
            return @([element floatValue]);
        }];
    });
}

FOX_EXPORT id<FOXGenerator> FOXDouble(void) {
    return FOXGenMap(FOXDecimalNumber(), ^FOXRoseTree *(FOXRoseTree *generatedTree) {
        return [generatedTree treeByApplyingBlock:^id(NSDecimalNumber *element) {
            return @([element doubleValue]);
        }];
    });
}

FOX_EXPORT id<FOXGenerator> FOXDecimalNumber(void) {
    return FOXSized(^id<FOXGenerator>(NSUInteger size) {
        id<FOXGenerator> genShort = FOXChoose(@(MAX(-size, INT16_MIN)), @(MIN(size, INT16_MAX)));
        return FOXBind(genShort, ^id<FOXGenerator>(NSNumber *exponent) {
            return FOXBind(FOXChoose(@0, @(size)), ^id<FOXGenerator>(NSNumber *mantissa) {
                return FOXBind(FOXBoolean(), ^id<FOXGenerator>(NSNumber *isNegative) {
                    if ([mantissa isEqual:@0]) {
                        return FOXReturn([NSDecimalNumber zero]);
                    }
                    return FOXReturn([NSDecimalNumber decimalNumberWithMantissa:[mantissa unsignedLongLongValue]
                                                                       exponent:[exponent shortValue]
                                                                     isNegative:[isNegative boolValue]]);
                });
            });
        });
    });
}

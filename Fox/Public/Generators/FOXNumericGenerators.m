#import "FOXNumericGenerators.h"
#import "FOXCoreGenerators.h"
#import "FOXGenerator.h"
#import "FOXArrayGenerators.h"


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
    id<FOXGenerator> generator = FOXTuple(@[FOXInteger(), FOXStrictPositiveInteger()]);
    return FOXWithName(@"Float", FOXMap(generator, ^id(NSArray *numbers) {
        NSInteger dividend = [numbers[0] integerValue];
        NSInteger divisor = [numbers[1] integerValue];
        return @((float)(dividend / divisor));
    }));
}

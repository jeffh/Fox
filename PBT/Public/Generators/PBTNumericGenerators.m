#import "PBTNumericGenerators.h"
#import "PBTCoreGenerators.h"
#import "PBTGenerator.h"


PBT_EXPORT id<PBTGenerator> _PBTNaturalInteger(void) {
    return PBTWithName(@"NaturalInteger", PBTMap(PBTInteger(), ^id(NSNumber *number) {
        return @(ABS([number integerValue]));
    }));
}

PBT_EXPORT id<PBTGenerator> PBTPositiveInteger(void) {
    return PBTWithName(@"PositiveInteger", _PBTNaturalInteger());
}

PBT_EXPORT id<PBTGenerator> PBTNegativeInteger(void) {
    return PBTWithName(@"NegativeInteger", PBTMap(_PBTNaturalInteger(), ^id(NSNumber *number) {
        return @(-[number integerValue]);
    }));
}

PBT_EXPORT id<PBTGenerator> PBTStrictPositiveInteger(void) {
    return PBTWithName(@"StrictPostiveInteger", PBTMap(_PBTNaturalInteger(), ^id(NSNumber *number) {
        return @([number integerValue] ?: 1);
    }));
}

PBT_EXPORT id<PBTGenerator> PBTStrictNegativeInteger(void) {
    return PBTWithName(@"StrictNegativeInteger", PBTMap(_PBTNaturalInteger(), ^id(NSNumber *number) {
        return @(-([number integerValue] ?: 1));
    }));
}

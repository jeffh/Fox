#import "FOXMacros.h"


@protocol FOXGenerator;
@protocol FOXSequence;


/// Generates a fixed-size array where each element is in the same order
/// as the specified sequence of generators.
FOX_EXPORT id<FOXGenerator> FOXTupleOfGenerators(id<FOXSequence> generators);

FOX_EXPORT id<FOXGenerator> FOXTuple(NSArray *generators);

FOX_EXPORT id<FOXGenerator> FOXArray(id<FOXGenerator> elementGenerator);

FOX_EXPORT id<FOXGenerator> FOXArrayOfSize(id<FOXGenerator> elementGenerator, NSUInteger numberOfElements);

FOX_EXPORT id<FOXGenerator> FOXArrayOfSizeRange(
    id<FOXGenerator> elementGenerator,
    NSUInteger minimumNumberOfElements,
    NSUInteger maximumNumberOfElements);


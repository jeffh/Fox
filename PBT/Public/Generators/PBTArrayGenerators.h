#import "PBTMacros.h"


@protocol PBTGenerator;
@protocol PBTSequence;


PBT_EXPORT id<PBTGenerator> PBTTuple(id<PBTSequence> generators);

PBT_EXPORT id<PBTGenerator> PBTTupleOfGenerators(NSArray *generators);

PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator);

PBT_EXPORT id<PBTGenerator> PBTArrayOfSize(id<PBTGenerator> elementGenerator, NSUInteger numberOfElements);

PBT_EXPORT id<PBTGenerator> PBTArrayOfSizeRange(
    id<PBTGenerator> elementGenerator,
    NSUInteger minimumNumberOfElements,
    NSUInteger maximumNumberOfElements);


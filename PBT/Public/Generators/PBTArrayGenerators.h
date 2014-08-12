#import "PBTMacros.h"


@protocol PBTGenerator;
@protocol PBTSequence;


PBT_EXPORT id<PBTGenerator> PBTTuple(id<PBTSequence> generators);

PBT_EXPORT id<PBTGenerator> PBTTuple(NSArray *generators);

PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator);

PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator, NSUInteger numberOfElements);

PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator,
                                     NSUInteger minimumNumberOfElements,
                                     NSUInteger maximumNumberOfElements);


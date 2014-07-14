#import <Foundation/Foundation.h>

@protocol PBTRandom;
@protocol PBTSequence;
@class PBTRoseTree;

// interface of generators will return id
typedef PBTRoseTree *(^PBTGenerator)(id<PBTRandom> random, NSNumber *size);

FOUNDATION_EXPORT PBTGenerator PBTGenPure(PBTRoseTree *tree);
FOUNDATION_EXPORT PBTGenerator PBTGenMap(PBTGenerator generator,
                                         PBTRoseTree *(^mapfn)(PBTRoseTree *generatorTree));
FOUNDATION_EXPORT PBTGenerator PBTGenBind(PBTGenerator generator,
                                          PBTGenerator (^generatorFactory)(PBTRoseTree *generatorTree));
FOUNDATION_EXPORT PBTGenerator PBTMap(PBTGenerator generator, id(^fn)(id roseTree));

FOUNDATION_EXPORT PBTGenerator PBTReturn(id value);
FOUNDATION_EXPORT PBTGenerator PBTInt();

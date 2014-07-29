#import "PBTMacros.h"

@protocol PBTRandom;
@protocol PBTSequence;
@class PBTRoseTree;


@protocol PBTGenerator <NSObject>

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize;

@end


PBT_EXPORT id<PBTGenerator> PBTGenPure(PBTRoseTree *tree);
PBT_EXPORT id<PBTGenerator> PBTGenMap(id<PBTGenerator> generator,
                                         PBTRoseTree *(^mapfn)(PBTRoseTree *generatorTree));
PBT_EXPORT id<PBTGenerator> PBTGenBind(id<PBTGenerator> generator,
                                              id<PBTGenerator> (^generatorFactory)(PBTRoseTree *generatorTree));
PBT_EXPORT id<PBTGenerator> PBTMap(id<PBTGenerator> generator, id(^fn)(id generatedValue));

PBT_EXPORT id<PBTGenerator> PBTChoose(NSNumber *lower, NSNumber *upper);
PBT_EXPORT id<PBTGenerator> PBTSized(id<PBTGenerator> (^fn)(NSUInteger size));

PBT_EXPORT id<PBTGenerator> PBTReturn(id value);
PBT_EXPORT id<PBTGenerator> PBTInteger(void);
PBT_EXPORT id<PBTGenerator> PBTPositiveInteger(void);
PBT_EXPORT id<PBTGenerator> PBTNegativeInteger(void);
PBT_EXPORT id<PBTGenerator> PBTStrictPositiveInteger(void);
PBT_EXPORT id<PBTGenerator> PBTStrictNegativeInteger(void);

PBT_EXPORT id<PBTGenerator> PBTSeq(id<PBTSequence> generators);
PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator);
PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator);

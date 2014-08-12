#import "PBTMacros.h"


@class PBTRoseTree;
@protocol PBTGenerator;


// Boxes the generator with a description that indicates its origin.
PBT_EXPORT id<PBTGenerator> PBTWithName(NSString *name, id<PBTGenerator> generator);

PBT_EXPORT id<PBTGenerator> PBTGenPure(PBTRoseTree *tree);

PBT_EXPORT id<PBTGenerator> PBTGenMap(id<PBTGenerator> generator,
                                      PBTRoseTree *(^mapfn)(PBTRoseTree *generatorTree));

PBT_EXPORT id<PBTGenerator> PBTGenBind(id<PBTGenerator> generator,
                                       id<PBTGenerator> (^generatorFactory)(PBTRoseTree *generatorTree));

PBT_EXPORT id<PBTGenerator> PBTMap(id<PBTGenerator> generator, id(^fn)(id generatedValue));

PBT_EXPORT id<PBTGenerator> PBTBind(id<PBTGenerator> generator, id<PBTGenerator> (^fn)(PBTRoseTree *generatedTree));

PBT_EXPORT id<PBTGenerator> PBTChoose(NSNumber *lower, NSNumber *upper);

PBT_EXPORT id<PBTGenerator> PBTSized(id<PBTGenerator> (^fn)(NSUInteger size));

PBT_EXPORT id<PBTGenerator> PBTReturn(id value);

PBT_EXPORT id<PBTGenerator> PBTInteger(void);

PBT_EXPORT id<PBTGenerator> PBTSuchThat(id<PBTGenerator> generator, BOOL(^predicate)(id generatedValue));

PBT_EXPORT id<PBTGenerator> PBTSuchThat(id<PBTGenerator> generator, BOOL(^predicate)(id generatedValue), NSUInteger maxTries);

PBT_EXPORT id<PBTGenerator> PBTOneOf(NSArray *generators);

PBT_EXPORT id<PBTGenerator> PBTElements(NSArray *elements);

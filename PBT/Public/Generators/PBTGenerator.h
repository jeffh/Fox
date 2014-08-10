#import "PBTMacros.h"

@protocol PBTRandom;
@protocol PBTSequence;
@protocol PBTStateMachine;
@class PBTRoseTree;


@protocol PBTGenerator <NSObject>

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize;

@end

// Boxes the generator with a description that indicates its origin.
PBT_EXPORT id<PBTGenerator> PBTWithName(NSString *name, id<PBTGenerator> generator);

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
PBT_EXPORT id<PBTGenerator> PBTCharacter(void);
PBT_EXPORT id<PBTGenerator> PBTAlphabetCharacter(void);
PBT_EXPORT id<PBTGenerator> PBTNumericCharacter(void);
PBT_EXPORT id<PBTGenerator> PBTAlphanumericCharacter(void);
PBT_EXPORT id<PBTGenerator> PBTAsciiCharacter(void);
PBT_EXPORT id<PBTGenerator> PBTString(void);

PBT_EXPORT id<PBTGenerator> PBTTuple(id<PBTSequence> generators);
PBT_EXPORT id<PBTGenerator> PBTTuple(NSArray *generators);

PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator);
PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator, NSUInteger numberOfElements);
PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator,
                                     NSUInteger minimumNumberOfElements,
                                     NSUInteger maximumNumberOfElements);

PBT_EXPORT id<PBTGenerator> PBTSet(id<PBTGenerator> elementGenerator);

/*! Generates values from a given dictionary template.
 *  The string are constant values while the values are generators.
 */
PBT_EXPORT id<PBTGenerator> PBTDictionary(NSDictionary *dictionaryTemplate);

PBT_EXPORT id<PBTGenerator> PBTSuchThat(id<PBTGenerator> generator, BOOL(^predicate)(id generatedValue));
PBT_EXPORT id<PBTGenerator> PBTSuchThat(id<PBTGenerator> generator, BOOL(^predicate)(id generatedValue), NSUInteger maxTries);

PBT_EXPORT id<PBTGenerator> PBTCommands(id<PBTStateMachine> stateMachine);

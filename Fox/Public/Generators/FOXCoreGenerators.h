#import "FOXMacros.h"


@class FOXRoseTree;
@protocol FOXGenerator;
@protocol FOXRandom;


/// Boxes the generator with a description that indicates its origin.
FOX_EXPORT id<FOXGenerator> FOXWithName(NSString *name, id<FOXGenerator> generator);

FOX_EXPORT id<FOXGenerator> FOXGenerate(FOXRoseTree *(^generator)(id<FOXRandom> random, NSUInteger size));

FOX_EXPORT id<FOXGenerator> FOXGenPure(FOXRoseTree *tree);

FOX_EXPORT id<FOXGenerator> FOXGenMap(
    id<FOXGenerator> generator,
    FOXRoseTree *(^mapfn)(FOXRoseTree *generatorTree));

FOX_EXPORT id<FOXGenerator> FOXGenBind(
    id<FOXGenerator> generator,
    id<FOXGenerator> (^generatorFactory)(FOXRoseTree *generatorTree));

FOX_EXPORT id<FOXGenerator> FOXMap(id<FOXGenerator> generator, id(^fn)(id generatedValue));

FOX_EXPORT id<FOXGenerator> FOXBind(id<FOXGenerator> generator, id<FOXGenerator> (^fn)(id generatedValue));

FOX_EXPORT id<FOXGenerator> FOXChoose(NSNumber *lower, NSNumber *upper);

FOX_EXPORT id<FOXGenerator> FOXSized(id<FOXGenerator> (^fn)(NSUInteger size));

FOX_EXPORT id<FOXGenerator> FOXReturn(id value);

FOX_EXPORT id<FOXGenerator> FOXInteger(void);

FOX_EXPORT id<FOXGenerator> FOXSuchThat(id<FOXGenerator> generator, BOOL(^predicate)(id generatedValue));

FOX_EXPORT id<FOXGenerator> FOXSuchThatWithMaxTries(id<FOXGenerator> generator, BOOL(^predicate)(id generatedValue), NSUInteger maxTries);

FOX_EXPORT id<FOXGenerator> FOXOneOf(NSArray *generators);

FOX_EXPORT id<FOXGenerator> FOXElements(NSArray *elements);

FOX_EXPORT id<FOXGenerator> FOXFrequency(NSArray *tuples);

FOX_EXPORT id<FOXGenerator> FOXResize(NSUInteger newSize, id<FOXGenerator> generator);

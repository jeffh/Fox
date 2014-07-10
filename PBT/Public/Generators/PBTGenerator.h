#import <Foundation/Foundation.h>

@protocol PBTRandom;
@protocol PBTSequence;

// interface of generators will return id
typedef id (^PBTGenerator)(id<PBTRandom> random, NSUInteger sizeFactor);
typedef id<PBTSequence> (^PBTSequenceGenerator)(id<PBTRandom> random, NSUInteger sizeFactor);

FOUNDATION_EXPORT PBTGenerator PBTGenPure(id value);
FOUNDATION_EXPORT PBTSequenceGenerator PBTGenMap(PBTGenerator generator, id(^mapfn)(id));
FOUNDATION_EXPORT PBTGenerator PBTGenBind(PBTSequenceGenerator generator,
                                          PBTGenerator (^generatorFactory)(id<PBTSequence> generatedSequence));


FOUNDATION_EXPORT PBTGenerator PBTReturn(id value);
FOUNDATION_EXPORT PBTGenerator (^PBTMap)(PBTGenerator, id(^)(id roseTree));

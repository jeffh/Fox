#import "FOXArrayGenerators.h"
#import "FOXTupleGenerator.h"
#import "FOXSequence.h"
#import "FOXCoreGenerators.h"
#import "FOXRoseTree.h"
#import "FOXArrayGenerator.h"


FOX_EXPORT id<FOXGenerator> FOXTupleOfGenerators(id<FOXSequence> generators) {
    return [[FOXTupleGenerator alloc] initWithGenerators:generators];
}

FOX_EXPORT id<FOXGenerator> FOXTuple(NSArray *generators) {
    return [[FOXTupleGenerator alloc] initWithGenerators:[FOXSequence sequenceFromArray:generators]];
}

FOX_EXPORT id<FOXGenerator> FOXArray(id<FOXGenerator> elementGenerator) {
    id<FOXGenerator> sizeGenerator = FOXSized(^id<FOXGenerator>(NSUInteger size) {
        return FOXChoose(@0, @(size));
    });
    return FOXWithName(@"Array", FOXGenBind(sizeGenerator, ^id<FOXGenerator>(FOXRoseTree *sizeTree) {
        id<FOXSequence> generators = [FOXSequence sequenceByRepeatingObject:elementGenerator
                                                                      times:[sizeTree.value integerValue]];
        return [[FOXArrayGenerator alloc] initWithGenerators:generators];
    }));
}

FOX_EXPORT id<FOXGenerator> FOXArrayOfSize(id<FOXGenerator> elementGenerator, NSUInteger numberOfElements) {
    id<FOXSequence> generators = [FOXSequence sequenceByRepeatingObject:elementGenerator
                                                                  times:numberOfElements];
    return FOXWithName(@"ArrayOfSize", FOXTupleOfGenerators(generators));
}

FOX_EXPORT id<FOXGenerator> FOXArrayOfSizeRange(id<FOXGenerator> elementGenerator,
                                                NSUInteger minimumNumberOfElements,
                                                NSUInteger maximumNumberOfElements) {
    id<FOXGenerator> sizedArrayGenerator = FOXGenerate(^FOXRoseTree *(id<FOXRandom> random, NSUInteger size) {
        return [FOXArrayOfSize(elementGenerator, size) lazyTreeWithRandom:random maximumSize:size];
    });
    sizedArrayGenerator = FOXWithName(@"ArrayOfSizeRange", sizedArrayGenerator);
    return FOXResizeRange(sizedArrayGenerator, minimumNumberOfElements, maximumNumberOfElements);
}

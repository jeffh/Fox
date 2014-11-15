#import "PBTArrayGenerators.h"
#import "PBTTupleGenerator.h"
#import "PBTSequence.h"
#import "PBTCoreGenerators.h"
#import "PBTRoseTree.h"
#import "PBTArrayGenerator.h"


PBT_EXPORT id<PBTGenerator> PBTTuple(id<PBTSequence> generators) {
    return [[PBTTupleGenerator alloc] initWithGenerators:generators];
}

PBT_EXPORT id<PBTGenerator> PBTTupleOfGenerators(NSArray *generators) {
    return [[PBTTupleGenerator alloc] initWithGenerators:[PBTSequence sequenceFromArray:generators]];
}

PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator) {
    id<PBTGenerator> sizeGenerator = PBTSized(^id<PBTGenerator>(NSUInteger size) {
        return PBTChoose(@0, @(size));
    });
    return PBTGenBind(sizeGenerator, ^id<PBTGenerator>(PBTRoseTree *sizeTree) {
        id<PBTSequence> generators = [PBTSequence sequenceByRepeatingObject:elementGenerator
                                                                      times:[sizeTree.value integerValue]];
        return [[PBTArrayGenerator alloc] initWithGenerators:generators];
    });
}

PBT_EXPORT id<PBTGenerator> PBTArrayOfSize(id<PBTGenerator> elementGenerator, NSUInteger numberOfElements) {
    id<PBTSequence> generators = [PBTSequence sequenceByRepeatingObject:elementGenerator
                                                                  times:numberOfElements];
    return PBTTuple(generators);
}

PBT_EXPORT id<PBTGenerator> PBTArrayOfSizeRange(id<PBTGenerator> elementGenerator,
    NSUInteger minimumNumberOfElements,
    NSUInteger maximumNumberOfElements) {
    id<PBTGenerator> sizeGenerator = PBTChoose(@(minimumNumberOfElements),
                                               @(maximumNumberOfElements));
    return PBTGenBind(sizeGenerator, ^id<PBTGenerator>(PBTRoseTree *sizeTree) {
        id<PBTSequence> generators = [PBTSequence sequenceByRepeatingObject:elementGenerator
                                                                      times:[sizeTree.value integerValue]];
        id<PBTGenerator> arrayGenerator = [[PBTArrayGenerator alloc] initWithGenerators:generators];
        return PBTGenBind(arrayGenerator, ^id<PBTGenerator>(PBTRoseTree *generatorTree) {
            return PBTGenPure([generatorTree treeFilterChildrenByBlock:^BOOL(NSArray *elements) {
                NSUInteger count = [elements count];
                return count >= minimumNumberOfElements && count <= maximumNumberOfElements;
            }]);
        });
    });
}

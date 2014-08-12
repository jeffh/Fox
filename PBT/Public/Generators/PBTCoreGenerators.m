#import "PBTCoreGenerators.h"
#import "PBTNamedGenerator.h"
#import "PBTRoseTree.h"
#import "PBTPureGenerator.h"
#import "PBTMapGenerator.h"
#import "PBTBindGenerator.h"
#import "PBTChooseGenerator.h"
#import "PBTSizedGenerator.h"
#import "PBTSuchThatGenerator.h"
#import "PBTBlockGenerator.h"


PBT_EXPORT id<PBTGenerator> PBTWithName(NSString *name, id<PBTGenerator> generator) {
    return [[PBTNamedGenerator alloc] initWithName:name forGenerator:generator];
}

PBT_EXPORT id<PBTGenerator> PBTGenPure(PBTRoseTree *tree) {
    return [[PBTPureGenerator alloc] initWithRoseTree:tree];
}

PBT_EXPORT id<PBTGenerator> PBTGenMap(id<PBTGenerator> generator,
                                      PBTRoseTree *(^mapfn)(PBTRoseTree *generatorTree)) {
    return [[PBTMapGenerator alloc] initWithGenerator:generator map:mapfn];
}

PBT_EXPORT id<PBTGenerator> PBTGenBind(id<PBTGenerator> generator,
                                       id<PBTGenerator> (^factory)(PBTRoseTree *generatorTree)) {
    return [[PBTBindGenerator alloc] initWithGenerator:generator factory:factory];
}

PBT_EXPORT id<PBTGenerator> PBTMap(id<PBTGenerator> generator, id (^fn)(id value)) {
    return PBTGenMap(generator, ^PBTRoseTree *(PBTRoseTree *roseTree) {
        return [roseTree treeByApplyingBlock:fn];
    });
}

PBT_EXPORT id<PBTGenerator> PBTChoose(NSNumber *lower, NSNumber *upper) {
    return [[PBTChooseGenerator alloc] initWithLowerBound:lower upperBound:upper];
}

PBT_EXPORT id<PBTGenerator> PBTSized(id<PBTGenerator> (^fn)(NSUInteger size)) {
    return [[PBTSizedGenerator alloc] initWithFactory:fn];
}

PBT_EXPORT id<PBTGenerator> PBTReturn(id value) {
    return PBTGenPure([[PBTRoseTree alloc] initWithValue:value]);
}

PBT_EXPORT id<PBTGenerator> PBTInteger(void) {
    return PBTWithName(@"Integer", PBTSized(^(NSUInteger sizeNumber){
        return PBTChoose(@(-((NSInteger)sizeNumber)), @(sizeNumber));
    }));
}

PBT_EXPORT id<PBTGenerator> PBTSuchThat(id<PBTGenerator> generator, BOOL(^predicate)(id)) {
    return PBTSuchThat(generator, predicate, 10);
}

PBT_EXPORT id<PBTGenerator> PBTSuchThat(id<PBTGenerator> generator, BOOL(^predicate)(id), NSUInteger maxTries) {
    return [[PBTSuchThatGenerator alloc] initWithGenerator:generator predicate:predicate maxTries:maxTries];
}

PBT_EXPORT id<PBTGenerator> PBTBind(id<PBTGenerator> generator, id<PBTGenerator> (^fn)(PBTRoseTree *generatedTree)) {
    return PBTGenBind(generator, ^id<PBTGenerator>(PBTRoseTree *generatorTree) {
        id<PBTGenerator> innerGenerator = [[PBTBlockGenerator alloc] initWithBlock:^PBTRoseTree *(id<PBTRandom> random, NSUInteger size) {
            return [[generatorTree treeByApplyingBlock:fn] treeByApplyingBlock:^id(id<PBTGenerator> gen) {
                return [gen lazyTreeWithRandom:random maximumSize:size];
            }];
        }];
        return PBTGenMap(innerGenerator, ^PBTRoseTree *(PBTRoseTree *innerTree) {
            return [PBTRoseTree joinedTreeFromNestedRoseTree:innerTree];
        });
    });
}

PBT_EXPORT id<PBTGenerator> PBTOneOf(NSArray *generators) {
    NSCAssert(([generators filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self conformsToProtocol: %@", @protocol(PBTGenerator)]].count),
              @"array elements do not all conform to @protocol(PBTGenerator)");
    return PBTWithName(@"OneOf", PBTGenBind(PBTChoose(@0, @(generators.count - 1)), ^id<PBTGenerator>(PBTRoseTree *sizeTree) {
        return generators[[sizeTree.value integerValue]];
    }));
}

PBT_EXPORT id<PBTGenerator> PBTElements(NSArray *elements) {
    NSCParameterAssert(elements.count);
    return PBTGenBind(PBTChoose(@0, @(elements.count - 1)), ^id<PBTGenerator>(PBTRoseTree *generatorTree) {
        return PBTGenPure([generatorTree treeByApplyingBlock:^id(NSNumber *number) {
            return elements[[number integerValue]];
        }]);
    });
}

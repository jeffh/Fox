#import "PBTGenerator.h"
#import "PBTBlockGenerator.h"
#import "PBTPureGenerator.h"
#import "PBTMapGenerator.h"
#import "PBTBindGenerator.h"
#import "PBTSizedGenerator.h"
#import "PBTChooseGenerator.h"
#import "PBTSequenceGenerator.h"
#import "PBTNamedGenerator.h"
#import "PBTStringGenerator.h"
#import "PBTArrayGenerator.h"
#import "PBTTupleGenerator.h"
#import "PBTConcreteSequence.h"
#import "PBTLazySequence.h"
#import "PBTRandom.h"
#import "PBTRoseTree.h"


PBT_EXPORT id<PBTGenerator> PBTWithName(NSString *name, id<PBTGenerator> generator) {
    return [[PBTNamedGenerator alloc] initWithName:name forGenerator:generator];
}

#pragma mark - Generators

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
};


PBT_EXPORT id<PBTGenerator> PBTReturn(id value) {
    return PBTGenPure([[PBTRoseTree alloc] initWithValue:value]);
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

PBT_EXPORT id<PBTGenerator> PBTTuple(id<PBTSequence> generators) {
    return [[PBTTupleGenerator alloc] initWithGenerators:generators];
}

PBT_EXPORT id<PBTGenerator> PBTTuple(NSArray *generators) {
    return [[PBTTupleGenerator alloc] initWithGenerators:[PBTSequence sequenceFromArray:generators]];
}

PBT_EXPORT id<PBTGenerator> PBTSized(id<PBTGenerator> (^fn)(NSUInteger size)) {
    return [[PBTSizedGenerator alloc] initWithFactory:fn];
}


PBT_EXPORT id<PBTGenerator> PBTChoose(NSNumber *lower, NSNumber *upper) {
    return [[PBTChooseGenerator alloc] initWithLowerBound:lower upperBound:upper];
}

PBT_EXPORT id<PBTGenerator> PBTOneOf(NSArray *generators) {
    NSCAssert(([generators filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self conformsToProtocol: %@", @protocol(PBTGenerator)]].count),
              @"array elements do not all conform to @protocol(PBTGenerator)");
    return PBTWithName(@"OneOf", PBTGenBind(PBTChoose(@0, @(generators.count - 1)), ^id<PBTGenerator>(PBTRoseTree *sizeTree) {
        return generators[[sizeTree.value integerValue]];
    }));
}

PBT_EXPORT id<PBTGenerator> PBTInteger(void) {
    return PBTWithName(@"Integer", PBTSized(^(NSUInteger sizeNumber){
        return PBTChoose(@(-((NSInteger)sizeNumber)), @(sizeNumber));
    }));
}

PBT_EXPORT id<PBTGenerator> _PBTNaturalInteger(void) {
    return PBTWithName(@"NaturalInteger", PBTMap(PBTInteger(), ^id(NSNumber *number) {
        return @(ABS([number integerValue]));
    }));
}

PBT_EXPORT id<PBTGenerator> PBTPositiveInteger(void) {
    return PBTWithName(@"PositiveInteger", _PBTNaturalInteger());
}

PBT_EXPORT id<PBTGenerator> PBTNegativeInteger(void) {
    return PBTWithName(@"NegativeInteger", PBTMap(_PBTNaturalInteger(), ^id(NSNumber *number) {
        return @(-[number integerValue]);
    }));
}

PBT_EXPORT id<PBTGenerator> PBTStrictPositiveInteger(void) {
    return PBTWithName(@"StrictPostiveInteger", PBTMap(_PBTNaturalInteger(), ^id(NSNumber *number) {
        return @([number integerValue] ?: 1);
    }));
}

PBT_EXPORT id<PBTGenerator> PBTStrictNegativeInteger(void) {
    return PBTWithName(@"StrictNegativeInteger", PBTMap(_PBTNaturalInteger(), ^id(NSNumber *number) {
        return @(-([number integerValue] ?: 1));
    }));
}

PBT_EXPORT id<PBTGenerator> PBTCharacter(void) {
    return PBTWithName(@"Character", PBTChoose(@0, @255));
}

PBT_EXPORT id<PBTGenerator> PBTAlphabetCharacter(void) {
    return PBTWithName(@"AlphabetCharacter", PBTOneOf(@[PBTChoose(@65, @90),
                                                        PBTChoose(@97, @122)]));
}

PBT_EXPORT id<PBTGenerator> PBTNumericCharacter(void) {
    return PBTWithName(@"NumbericCharacter", PBTChoose(@48, @57));
}

PBT_EXPORT id<PBTGenerator> PBTAlphanumericCharacter(void) {
    return PBTWithName(@"AlphanumericCharacter", PBTOneOf(@[PBTChoose(@48, @57),
                                                            PBTChoose(@65, @90),
                                                            PBTChoose(@97, @122)]));
}

PBT_EXPORT id<PBTGenerator> PBTAsciiCharacter(void) {
    return PBTWithName(@"AsciiCharacter", PBTChoose(@32, @126));
}

PBT_EXPORT id<PBTGenerator> PBTString(void) {
    return [[PBTStringGenerator alloc] initWithArrayOfIntegersGenerator:PBTArray(PBTCharacter()) name:@"Any"];
}

PBT_EXPORT id<PBTGenerator> PBTAsciiString(void) {
    return [[PBTStringGenerator alloc] initWithArrayOfIntegersGenerator:PBTArray(PBTAsciiCharacter()) name:@"Ascii"];
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

PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator, NSUInteger numberOfElements) {
    id<PBTSequence> generators = [PBTSequence sequenceByRepeatingObject:elementGenerator
                                                                  times:numberOfElements];
    return PBTTuple(generators);
}

PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator,
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

PBT_EXPORT id<PBTGenerator> PBTSet(id<PBTGenerator> elementGenerator) {
    return PBTMap(PBTArray(elementGenerator), ^id(NSArray *elements) {
        return [NSSet setWithArray:elements];
    });
}

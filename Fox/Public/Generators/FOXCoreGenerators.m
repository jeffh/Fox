#import "FOXCoreGenerators.h"
#import "FOXNamedGenerator.h"
#import "FOXRoseTree.h"
#import "FOXPureGenerator.h"
#import "FOXMapGenerator.h"
#import "FOXBindGenerator.h"
#import "FOXChooseGenerator.h"
#import "FOXSizedGenerator.h"
#import "FOXSuchThatGenerator.h"
#import "FOXBlockGenerator.h"

#import "FOXSequence.h"


FOX_EXPORT id<FOXGenerator> FOXWithName(NSString *name, id<FOXGenerator> generator) {
    return [[FOXNamedGenerator alloc] initWithName:name forGenerator:generator];
}

FOX_EXPORT id<FOXGenerator> FOXGenerate(FOXRoseTree *(^generator)(id<FOXRandom> random, NSUInteger size)) {
    return [[FOXBlockGenerator alloc] initWithBlock:generator];
}

FOX_EXPORT id<FOXGenerator> FOXGenPure(FOXRoseTree *tree) {
    return [[FOXPureGenerator alloc] initWithRoseTree:tree];
}

FOX_EXPORT id<FOXGenerator> FOXGenMap(id<FOXGenerator> generator,
    FOXRoseTree *(^mapfn)(FOXRoseTree *generatedTree)) {
    return [[FOXMapGenerator alloc] initWithGenerator:generator map:mapfn];
}

FOX_EXPORT id<FOXGenerator> FOXGenBind(id<FOXGenerator> generator,
    id<FOXGenerator> (^factory)(FOXRoseTree *generatedTree)) {
    return [[FOXBindGenerator alloc] initWithGenerator:generator factory:factory];
}

FOX_EXPORT id<FOXGenerator> FOXMap(id<FOXGenerator> generator, id (^fn)(id generatedValue)) {
    return FOXGenMap(generator, ^FOXRoseTree *(FOXRoseTree *roseTree) {
        return [roseTree treeByApplyingBlock:fn];
    });
}

FOX_EXPORT id<FOXGenerator> FOXChoose(NSNumber *lower, NSNumber *upper) {
    return [[FOXChooseGenerator alloc] initWithLowerBound:lower upperBound:upper];
}

FOX_EXPORT id<FOXGenerator> FOXChooseRange(FOXRange range) {
    return FOXChoose(@(range.start), @(range.end));
}

FOX_EXPORT id<FOXGenerator> FOXSized(id<FOXGenerator> (^fn)(NSUInteger size)) {
    return [[FOXSizedGenerator alloc] initWithFactory:fn];
}

FOX_EXPORT id<FOXGenerator> FOXReturn(id value) {
    return FOXGenPure([[FOXRoseTree alloc] initWithValue:value]);
}

FOX_EXPORT id<FOXGenerator> FOXSuchThat(id<FOXGenerator> generator, BOOL(^predicate)(id)) {
    return FOXSuchThatWithMaxTries(generator, predicate, 10);
}

FOX_EXPORT id<FOXGenerator> FOXSuchThatWithMaxTries(id<FOXGenerator> generator, BOOL(^predicate)(id), NSUInteger maxTries) {
    return [[FOXSuchThatGenerator alloc] initWithGenerator:generator predicate:predicate maxTries:maxTries];
}

FOX_EXPORT id<FOXGenerator> FOXBind(id<FOXGenerator> generator, id<FOXGenerator> (^fn)(id value)) {
    return FOXGenBind(generator, ^id<FOXGenerator>(FOXRoseTree *generatorTree) {
        id<FOXGenerator> innerGenerator = FOXGenerate(^FOXRoseTree *(id<FOXRandom> random, NSUInteger size) {
            return [[generatorTree treeByApplyingBlock:fn] treeByApplyingBlock:^id(id<FOXGenerator> gen) {
                return [gen lazyTreeWithRandom:random maximumSize:size];
            }];
        });
        return FOXGenMap(innerGenerator, ^FOXRoseTree *(FOXRoseTree *innerTree) {
            return [FOXRoseTree joinedTreeFromNestedRoseTree:innerTree];
        });
    });
}

FOX_EXPORT id<FOXGenerator> FOXOneOf(NSArray *generators) {
    NSCAssert(([generators filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self conformsToProtocol: %@", @protocol(FOXGenerator)]].count),
              @"array elements do not all conform to @protocol(FOXGenerator)");
    return FOXWithName(@"OneOf", FOXGenBind(FOXChoose(@0, @(generators.count - 1)), ^id<FOXGenerator>(FOXRoseTree *sizeTree) {
        NSUInteger index = (NSUInteger)[sizeTree.value integerValue];
        return generators[index];
    }));
}

FOX_EXPORT id<FOXGenerator> FOXElements(NSArray *elements) {
    NSCParameterAssert(elements.count);
    return FOXWithName(@"FOXElements", FOXGenBind(FOXChoose(@0, @(elements.count - 1)), ^id<FOXGenerator>(FOXRoseTree *generatorTree) {
        return FOXGenPure([generatorTree treeByApplyingBlock:^id(NSNumber *number) {
            NSUInteger index = (NSUInteger)[number integerValue];
            return elements[index];
        }]);
    }));
}

FOX_EXPORT id<FOXGenerator> FOXFrequency(NSArray *tuples) {
    NSCAssert(tuples.count, @"FOXFrequency requires an array of (probability_uint, generator) tuples");
    NSUInteger total = 0;
    for (NSArray *pair in tuples) {
        NSCAssert(pair.count == 2, @"FOXFrequency accepts an array of tuples in @[probability_uint, generator] form");
        NSNumber *probability = pair.firstObject;

        NSCAssert([probability isKindOfClass:[NSNumber class]], @"first element in tuple is not an NSNumber (NSUInteger): %@", probability);
        NSCAssert([pair.lastObject conformsToProtocol:@protocol(FOXGenerator)], @"second element in tuple is not an FOXGenerator: %@", pair.lastObject);

        total += [probability unsignedIntegerValue];
    }

    return FOXWithName(@"FOXFrequency", FOXGenBind(FOXChoose(@1, @(total)), ^id<FOXGenerator>(FOXRoseTree *generatedTree) {
        NSUInteger roll = [generatedTree.value unsignedIntegerValue];
        NSUInteger rollingSum = 0;
        for (NSArray *pair in tuples) {
            NSUInteger probability = [pair.firstObject unsignedIntegerValue];
            id<FOXGenerator> generator = pair.lastObject;

            if (roll - rollingSum <= probability) {
                return generator;
            } else {
                rollingSum += probability;
            }
        }
        [NSException raise:NSInternalInconsistencyException
                    format:@"Failed to pick a generator (roll: %lu, tuples: %@)", (unsigned long)roll, tuples];
        return nil;
    }));
}

FOX_EXPORT id<FOXGenerator> FOXResize(id<FOXGenerator> generator, NSUInteger newSize) {
    return FOXWithName(@"FOXResize", FOXGenerate(^FOXRoseTree *(id<FOXRandom> random, NSUInteger _) {
        return [generator lazyTreeWithRandom:random maximumSize:newSize];
    }));
}

FOX_EXPORT id<FOXGenerator> FOXResizeRange(id<FOXGenerator> generator, NSUInteger minRange, NSUInteger maxRange) {
    NSUInteger delta = maxRange - minRange;
    return FOXWithName(@"ResizeRange", FOXGenerate(^FOXRoseTree *(id<FOXRandom> random, NSUInteger size) {
        if (delta) {
            return [generator lazyTreeWithRandom:random maximumSize:(size % delta) + minRange];
        } else {
            return [generator lazyTreeWithRandom:random maximumSize:size];
        }
    }));
}

#import "FOXDebugging.h"
#import "FOXRoseTree.h"
#import "FOXSequence.h"
#import "FOXRandom.h"
#import "FOXDeterministicRandom.h"
#import "FOXEnvironment.h"
#import "FOXGenerator.h"

FOX_EXPORT NSArray *FOXSample(id<FOXGenerator> generator) {
    return FOXSampleWithCount(generator, 10);
}

FOX_EXPORT NSArray *FOXSampleWithCount(id<FOXGenerator> generator, NSUInteger numberOfSamples) {
    id<FOXRandom> random = [[FOXDeterministicRandom alloc] init];
    NSMutableArray *samples = [NSMutableArray array];
    for (NSUInteger i = 0; i<numberOfSamples; i++) {
        FOXRoseTree *tree = [generator lazyTreeWithRandom:random maximumSize:FOXGetMaximumSize()];
        [samples addObject:tree.value ?: [NSNull null]];
    }
    return samples;
}


FOX_EXPORT NSArray *FOXSampleShrinking(id<FOXGenerator> generator) {
    return FOXSampleShrinkingWithCount(generator, 10);
}

FOX_EXPORT NSArray *FOXSampleShrinkingWithCount(id<FOXGenerator> generator, NSUInteger numberOfSamples) {
    id<FOXRandom> random = [[FOXDeterministicRandom alloc] initWithSeed:(uint32_t)FOXGetSeed()];
    FOXRoseTree *tree = [generator lazyTreeWithRandom:random maximumSize:50];
    NSMutableArray *stack = [NSMutableArray arrayWithObject:tree];
    NSMutableArray *samples = [NSMutableArray array];
    while (stack.count && samples.count < numberOfSamples) {
        tree = stack[0];
        [stack removeObjectAtIndex:0];
        [samples addObject:tree.value];
        [stack addObjectsFromArray:[[tree.children objectEnumerator] allObjects]];
    }

    return samples;
}

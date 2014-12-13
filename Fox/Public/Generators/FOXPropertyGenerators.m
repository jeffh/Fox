#import "FOXPropertyGenerators.h"
#import "FOXCoreGenerators.h"
#import "FOXGenerator.h"
#import "FOXRandom.h"
#import "FOXRoseTree.h"
#import "FOXSequence.h"


FOX_EXPORT id<FOXGenerator> FOXForAll(id<FOXGenerator> generator, BOOL (^then)(id generatedValue)) {
    return FOXWithName(@"FOXForAll", FOXForSome(generator, ^FOXPropertyStatus(id generatedValue) {
        return FOXRequire(then(generatedValue));
    }));
}

FOX_EXPORT id<FOXGenerator> FOXForSome(id<FOXGenerator> generator, FOXPropertyStatus (^verifier)(id generatedValue)) {
    return FOXWithName(@"FOXForSome", FOXMap(generator, ^id(id value) {
        FOXPropertyResult *result = [[FOXPropertyResult alloc] init];
        result.generatedValue = value;
        @try {
            result.status = verifier(value);
        }
        @catch (NSException *exception) {
            result.uncaughtException = exception;
            result.status = FOXPropertyStatusUncaughtException;
        }
        return result;
    }));
}

FOX_EXPORT id<FOXGenerator> FOXAlways(NSUInteger times, id<FOXGenerator> property) {
    return FOXWithName(@"Always", FOXGenerate(^FOXRoseTree *(id<FOXRandom> random, NSUInteger size) {
        NSUInteger repetition = MAX(times, 1);
        NSMutableArray *trees = [NSMutableArray arrayWithCapacity:repetition];
        for (NSUInteger i = 0; i < repetition; i++) {
            FOXRoseTree *roseTree = [property lazyTreeWithRandom:[random copy] maximumSize:size];
            [trees addObject:roseTree];
        }
        FOXRoseTree *treeArray = [FOXRoseTree zipTreeFromRoseTrees:trees];
        return [treeArray treeByApplyingBlock:^id(NSArray *propertyResults) {
            for (FOXPropertyResult *result in propertyResults) {
                if ([result hasFailedOrRaisedException]) {
                    return result;
                }
            }
            return [propertyResults firstObject];
        }];
    }));
}

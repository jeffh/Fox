#import "PBTGenerator.h"
#import "PBTConcreteSequence.h"
#import "PBTLazySequence.h"
#import "PBTRandom.h"
#import "PBTRoseTree.h"


#pragma mark - Generators

FOUNDATION_EXPORT PBTGenerator PBTGenPure(PBTRoseTree *tree) {
    return ^(id<PBTRandom> random, NSNumber *size) {
        return tree;
    };
}

FOUNDATION_EXPORT PBTGenerator PBTGenMap(PBTGenerator generator,
                                         PBTRoseTree *(^mapfn)(PBTRoseTree *generatorTree)) {
    return ^(id<PBTRandom> random, NSNumber *size) {
        return mapfn(generator(random, size));
    };
}

FOUNDATION_EXPORT PBTGenerator PBTGenBind(PBTGenerator generator,
                                          PBTGenerator (^factory)(PBTRoseTree *generatorTree)) {
    return ^(id<PBTRandom> random, NSNumber *size) {
        PBTRoseTree *innerTree = generator(random, size);
        PBTGenerator resultingGenerator = factory(innerTree);
        return resultingGenerator(random, size);
    };
}

FOUNDATION_EXPORT PBTGenerator PBTMap(PBTGenerator generator, id (^fn)(id value)) {
    return PBTGenMap(generator, ^PBTRoseTree *(PBTRoseTree *roseTree) {
        return [roseTree treeByApplyingBlock:fn];
    });
};


FOUNDATION_EXPORT PBTGenerator PBTReturn(id value) {
    return PBTGenPure([[PBTRoseTree alloc] initWithValue:value]);
}

FOUNDATION_EXPORT PBTGenerator PBTSized(id (^fn)(NSNumber *size)) {
    return ^(id<PBTRandom> random, NSNumber *size) {
        PBTGenerator sizedGen = fn(size);
        return sizedGen(random, size);
    };
}

FOUNDATION_EXPORT id<PBTSequence> PBTHalf(NSNumber *number) {
    if ([number compare:@0] == NSOrderedSame) {
        return nil;
    }
    return [[PBTConcreteSequence alloc] initWithObject:number
                                     remainingSequence:PBTHalf(@([number longLongValue] / 2))];
}

FOUNDATION_EXPORT id<PBTSequence> PBTShrinkInt(NSNumber *number) {
    return [PBTHalf(number) sequenceByApplyingBlock:^id(NSNumber *value) {
        return @([number longLongValue] - [value longLongValue]);
    }];
}

FOUNDATION_EXPORT PBTRoseTree *PBTIntRoseTree(NSNumber *number) {
    return [[PBTRoseTree alloc] initWithValue:number
                                     children:[PBTShrinkInt(number) sequenceByApplyingBlock:^id(NSNumber *value) {
        return PBTIntRoseTree(value);
    }]];
}

FOUNDATION_EXPORT PBTGenerator PBTChoose(NSNumber *lower, NSNumber *upper) {
    return ^(id<PBTRandom> random, NSNumber *size) {
        NSNumber *randValue = @([random randomDoubleWithinMinimum:[lower doubleValue]
                                                       andMaximum:[upper doubleValue]]);
        id<PBTSequence> seqOfTrees = PBTShrinkInt(randValue);
        seqOfTrees = [seqOfTrees sequenceByApplyingBlock:^id(id value) {
            return PBTIntRoseTree(value);
        }];
        PBTRoseTree *tree = [[PBTRoseTree alloc] initWithValue:randValue children:seqOfTrees];
        return [tree treeFilteredByBlock:^BOOL(NSNumber *value) {
            return [value compare:lower] != NSOrderedAscending
                && [value compare:upper] != NSOrderedDescending;
        }];
    };
}

FOUNDATION_EXPORT PBTGenerator PBTInt() {
    return PBTSized(^id(NSNumber *sizeNumber){
        return PBTChoose(@(-[sizeNumber integerValue]), sizeNumber);
    });
}

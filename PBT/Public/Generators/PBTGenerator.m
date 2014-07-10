#import "PBTGenerator.h"
#import "PBTConcreteSequence.h"
#import "PBTLazySequence.h"
#import "PBTRandom.h"

#pragma mark - PBTSeq Operations

FOUNDATION_EXPORT NSArray *PBTSeqMap(id<NSFastEnumeration> seq, id(^fn)(id)) {
    return nil;
}

#pragma mark - Rose Tree

FOUNDATION_EXPORT id<PBTSequence> PBTRTMap(id<PBTSequence> roseTree, id(^fn)(id)) {
    if (!roseTree) {
        return nil;
    }
    return [[PBTLazySequence alloc] initWithLazyBlock:^id<PBTSequence>{
        return [[PBTConcreteSequence alloc] initWithObject:fn([roseTree firstObject])
                                         remainingSequence:PBTRTMap([roseTree remainingSequence], fn)];
    }];
}

#pragma mark - Generators

FOUNDATION_EXPORT PBTSequenceGenerator PBTGenPure(id value) {
    return ^id<PBTSequence>(id<PBTRandom> random, NSUInteger sizeFactor) {
        return [[PBTConcreteSequence alloc] initWithObject:value];
    };
}

id<PBTSequence> PBTMapSequence(id<PBTSequence> sequence, id(^mapfn)(id)) {
    if (sequence) {
        return [[PBTLazySequence alloc] initWithLazyBlock:^id<PBTSequence>{
            return [[PBTConcreteSequence alloc] initWithObject:mapfn([sequence firstObject])
                                             remainingSequence:PBTMapSequence([sequence remainingSequence],
                                                                              mapfn)];
        }];
    } else {
        return nil;
    }
}

FOUNDATION_EXPORT PBTSequenceGenerator PBTGenMap(PBTGenerator generator, id(^mapfn)(id)) {
    return ^id<PBTSequence>(id<PBTRandom> random, NSUInteger sizeFactor) {
        return PBTMapSequence(generator(random, sizeFactor), mapfn);
    };
}

FOUNDATION_EXPORT PBTGenerator PBTGenBind(PBTSequenceGenerator generator,
                                          PBTGenerator (^generatorFactory)(id<PBTSequence> generatedSequence)) {
    return ^id(id<PBTRandom> random, NSUInteger sizeFactor) {
        id<PBTSequence> innerSeq = generator(random, sizeFactor);
        PBTGenerator resultingGenerator = generatorFactory(innerSeq);
        return resultingGenerator(random, sizeFactor);
    };
}

PBTGenerator PBTReturn(id value) {
    return PBTGenPure([[PBTConcreteSequence alloc] initWithObject:value]);
}

PBTGenerator (^PBTMap)(PBTGenerator, id(^)(id)) = ^(PBTGenerator generator, id(^fn)(id)){
    return ^id(id<PBTRandom> random, NSUInteger sizeFactor) {
        return PBTRTMap(generator(random, sizeFactor), fn);
    };
};

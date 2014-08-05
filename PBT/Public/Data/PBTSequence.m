#import "PBTSequence.h"
#import "PBTLazySequence.h"
#import "PBTConcreteSequence.h"
#import "PBTSequenceEnumerator.h"


@implementation PBTSequence {
    NSUInteger _cache;
}

#pragma - Constructors

- (id)init
{
    if (self = [super init]) {
        _cache = NSNotFound;
    }
    return self;
}

#pragma mark - PBTSequence

- (NSUInteger)count
{
    if (_cache == NSNotFound) {
        @synchronized (self) {
            if ([self firstObject]) {
                _cache = 1 + [[self remainingSequence] count];
            } else {
                _cache = 0;
            }
        }
    }
    return _cache;
}

- (NSEnumerator *)objectEnumerator
{
    return [[PBTSequenceEnumerator alloc] initWithSequence:self];
}

- (id<PBTSequence>)sequenceByApplyingIndexedBlock:(id(^)(NSUInteger index, id item))block
{
    return [self sequenceByApplyingIndexedBlock:block startingIndex:0];
}

- (id<PBTSequence>)sequenceByApplyingIndexedBlock:(id(^)(NSUInteger index, id item))block startingIndex:(NSUInteger)index
{
    return [[PBTLazySequence alloc] initWithLazyBlock:^id<PBTSequence>{
        if (![self firstObject]) {
            return [PBTSequence sequence];
        }
        id transformedFirstObject = block(index, [self firstObject]);
        id<PBTSequence> transformedRemainingSeq = [[self remainingSequence] sequenceByApplyingIndexedBlock:block startingIndex:index + 1];
        return [[PBTConcreteSequence alloc] initWithObject:transformedFirstObject
                                         remainingSequence:transformedRemainingSeq];
    }];
}

- (id<PBTSequence>)sequenceByApplyingBlock:(id (^)(id))block
{
    return [[PBTLazySequence alloc] initWithLazyBlock:^id<PBTSequence>{
        if (![self firstObject]) {
            return [PBTSequence sequence];
        }
        id transformedFirstObject = block([self firstObject]);
        id<PBTSequence> transformedRemainingSeq = [[self remainingSequence] sequenceByApplyingBlock:block];
        return [[PBTConcreteSequence alloc] initWithObject:transformedFirstObject
                                             remainingSequence:transformedRemainingSeq];
    }];
}

- (id<PBTSequence>)sequenceFilteredByBlock:(BOOL (^)(id))predicate
{
    return [[PBTLazySequence alloc] initWithLazyBlock:^id<PBTSequence>{
        if (![self firstObject]) {
            return [PBTSequence sequence];
        }

        id<PBTSequence> filteredRemainingSeq = [[self remainingSequence] sequenceFilteredByBlock:predicate];
        if (predicate([self firstObject])) {
            return [[PBTConcreteSequence alloc] initWithObject:[self firstObject]
                                             remainingSequence:filteredRemainingSeq];
        } else {
            return filteredRemainingSeq;
        }
    }];
}

- (id<PBTSequence>)sequenceByConcatenatingSequence:(id<PBTSequence>)sequence
{
    return [[PBTLazySequence alloc] initWithLazyBlock:^id<PBTSequence>{
        if ([self firstObject]) {
            id<PBTSequence> remainingSequence = [[self remainingSequence] sequenceByConcatenatingSequence:sequence];
            if (!remainingSequence) {
                remainingSequence = sequence;
            }
            return [[PBTConcreteSequence alloc] initWithObject:[self firstObject]
                                             remainingSequence:remainingSequence];
        } else {
            return sequence;
        }
    }];
}

- (id<PBTSequence>)sequenceByExcludingIndex:(NSUInteger)index
{
    return [PBTSequence lazySequenceFromBlock:^id<PBTSequence>{
        if (index == 0) {
            return [self remainingSequence];
        } else {
            return [[self class] sequenceWithObject:[self firstObject]
                                  remainingSequence:[[self remainingSequence] sequenceByExcludingIndex:index - 1]];
        }
    }];
}


- (id)objectByReducingWithSeed:(id)seedObject
                       reducer:(id(^)(id accum, id item))reducer
{
    id accum = seedObject;
    for (id item in self) {
        accum = reducer(accum, item);
    }
    return accum;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])buffer
                                    count:(NSUInteger)batchSize
{
    const unsigned long firstTimeState = 0;
    const unsigned long processingState = 1;
    if (state->state == firstTimeState) {
        state->mutationsPtr = (__bridge void *)self;
        state->extra[0] = (unsigned long)self;
        state->state = processingState;
    }
    NSUInteger objectsCaptured = 0;
    id<PBTSequence> seq = (__bridge id)(void *)(state->extra[0]);

    if (!seq) {
        return 0;
    }

    state->itemsPtr = buffer;

    while (objectsCaptured < batchSize && seq) {
        id object = [seq firstObject];
        if (!object) {
            break;
        }

        *buffer++ = object;
        seq = [seq remainingSequence];
        objectsCaptured++;
    }

    state->extra[0] = (unsigned long)seq;
    return objectsCaptured;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other
{
    if (![other conformsToProtocol:@protocol(PBTSequence)]) {
        return [self firstObject] == nil && other == nil;
    }

    id firstObject = [self firstObject];
    id<PBTSequence> remainingSequence = [self remainingSequence];
    id otherFirstObject = [other firstObject];
    if (firstObject != otherFirstObject && ![firstObject isEqual:otherFirstObject]) {
        return NO;
    }

    id otherRemainingSequence = [other remainingSequence];
    return remainingSequence == otherRemainingSequence || [remainingSequence isEqual:otherRemainingSequence];
}

- (NSUInteger)hash
{
    return [[self firstObject] hash] + [[self remainingSequence] hash];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"SEQ("];

    NSUInteger count = 0;
    for (id object in self) {
        [description appendFormat:@"%@, ", object];
        if (count++ > 8) {
            [description appendFormat:@"...  "];
            break;
        }
    }

    if (count) {
        [description deleteCharactersInRange:NSMakeRange(description.length - 2, 2)];
    }
    [description appendString:@")"];
    return description;
}

#pragma mark - Abstract PBTSequence

- (id<PBTSequence>)remainingSequence
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)firstObject
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

@implementation PBTSequence (EagarConstructors)

+ (instancetype)sequence
{
    return [[PBTConcreteSequence alloc] init];
}

+ (instancetype)sequenceWithObject:(id)firstObject
{
    return [[PBTConcreteSequence alloc] initWithObject:firstObject];
}

+ (instancetype)sequenceWithObject:(id)firstObject remainingSequence:(id<PBTSequence>)remainingSequence
{
    return [[PBTConcreteSequence alloc] initWithObject:firstObject remainingSequence:remainingSequence];
}

+ (instancetype)sequenceFromArray:(NSArray *)array
{
    id<PBTSequence> seq = nil;
    for (id item in [array reverseObjectEnumerator]) {
        seq = [[PBTConcreteSequence alloc] initWithObject:item remainingSequence:seq];
    }
    return seq ?: [[PBTConcreteSequence alloc] init];
}

+ (instancetype)sequenceByRepeatingObject:(id)object times:(NSUInteger)times
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:times];
    for (NSUInteger i = 0; i<times; i++) {
        [array addObject:object];
    }
    return [PBTConcreteSequence sequenceFromArray:array];
}

@end


@implementation PBTSequence (LazyConstructors)

+ (instancetype)lazySequenceByConcatenatingSequences:(NSArray *)sequences
{
    id<PBTSequence> result = [sequences firstObject];
    for (id<PBTSequence> seq in sequences) {
        if (seq != result) {
            result = [result sequenceByConcatenatingSequence:seq];
        }
    }
    return result;
}

+ (instancetype)lazySequenceFromBlock:(id<PBTSequence>(^)())block
{
    return [[PBTLazySequence alloc] initWithLazyBlock:block];
}

@end

#import "FOXSequence.h"
#import "FOXLazySequence.h"
#import "FOXConcreteSequence.h"
#import "FOXSequenceEnumerator.h"


@implementation FOXSequence

#pragma - Constructors

- (id)init
{
    if (self = [super init]) {
        _count = NSNotFound;
    }
    return self;
}

#pragma mark - FOXSequence

- (NSUInteger)count
{
    @synchronized (self) {
        if (_count == NSNotFound) {
            if ([self firstObject]) {
                _count = 1 + [[self remainingSequence] count];
            } else {
                _count = 0;
            }
        }
        return _count;
    }
}

- (NSEnumerator *)objectEnumerator
{
    return [[FOXSequenceEnumerator alloc] initWithSequence:self];
}

- (id<FOXSequence>)sequenceByMappingWithIndex:(id(^)(NSUInteger index, id item))block
{
    return [self sequenceByMappingWithIndex:block startingIndex:0];
}

- (id<FOXSequence>)sequenceByMappingWithIndex:(id(^)(NSUInteger index, id item))block startingIndex:(NSUInteger)index
{
    return [[FOXLazySequence alloc] initWithLazyBlock:^id<FOXSequence>{
        if (![self firstObject]) {
            return [[self class] sequence];
        }
        id transformedFirstObject = block(index, [self firstObject]);
        id<FOXSequence> transformedRemainingSeq = [[self remainingSequence] sequenceByMappingWithIndex:block
                                                                                         startingIndex:index + 1];
        return [[self class] sequenceWithObject:transformedFirstObject
                              remainingSequence:transformedRemainingSeq];
    }];
}

- (id<FOXSequence>)sequenceByMapping:(id(^)(id item))block
{
    return [[FOXLazySequence alloc] initWithLazyBlock:^id<FOXSequence>{
        if (![self firstObject]) {
            return [FOXSequence sequence];
        }
        id transformedFirstObject = block([self firstObject]);
        id<FOXSequence> transformedRemainingSeq = [[self remainingSequence] sequenceByMapping:block];
        return [[self class] sequenceWithObject:transformedFirstObject
                              remainingSequence:transformedRemainingSeq];
    }];
}

- (id<FOXSequence>)sequenceByFiltering:(BOOL (^)(id item))predicate
{
    return [[FOXLazySequence alloc] initWithLazyBlock:^id<FOXSequence>{
        if (![self firstObject]) {
            return [[self class] sequence];
        }

        id<FOXSequence> filteredRemainingSeq = [[self remainingSequence] sequenceByFiltering:predicate];
        if (predicate([self firstObject])) {
            return [[self class] sequenceWithObject:[self firstObject]
                                  remainingSequence:filteredRemainingSeq];
        } else {
            return filteredRemainingSeq;
        }
    }];
}

- (id<FOXSequence>)sequenceByAppending:(id<FOXSequence>)sequence
{
    return [[FOXLazySequence alloc] initWithLazyBlock:^id<FOXSequence>{
        if ([self firstObject]) {
            id<FOXSequence> remainingSequence = [[self remainingSequence] sequenceByAppending:sequence];
            if (!remainingSequence) {
                remainingSequence = sequence;
            }
            return [[self class] sequenceWithObject:[self firstObject]
                                  remainingSequence:remainingSequence];
        } else {
            return sequence;
        }
    }];
}

- (id<FOXSequence>)sequenceByDroppingIndex:(NSUInteger)index
{
    return [FOXSequence lazySequenceFromBlock:^id<FOXSequence> {
        if (index == 0) {
            return [self remainingSequence];
        } else {
            return [[self class] sequenceWithObject:[self firstObject]
                                  remainingSequence:[[self remainingSequence] sequenceByDroppingIndex:index - 1]];
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
    id<FOXSequence> seq = (__bridge id)(void *)(state->extra[0]);

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
    if (![other conformsToProtocol:@protocol(FOXSequence)]) {
        return [self firstObject] == nil && other == nil;
    }

    id firstObject = [self firstObject];
    id<FOXSequence> remainingSequence = [self remainingSequence];
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

#pragma mark - Abstract FOXSequence

- (id<FOXSequence>)remainingSequence
{
    NSAssert(NO, @"%@ is a subclass of FOXSequence and must implement -[%@])",
             NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)firstObject
{
    NSAssert(NO, @"%@ is a subclass of FOXSequence and must implement -[%@])",
             NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

@implementation FOXSequence (EagerConstructors)

+ (instancetype)sequence
{
    return [[FOXConcreteSequence alloc] init];
}

+ (instancetype)sequenceWithObject:(id)firstObject
{
    return [[FOXConcreteSequence alloc] initWithObject:firstObject];
}

+ (instancetype)sequenceWithObject:(id)firstObject remainingSequence:(id<FOXSequence>)remainingSequence
{
    return [[FOXConcreteSequence alloc] initWithObject:firstObject remainingSequence:remainingSequence];
}

+ (instancetype)sequenceFromArray:(NSArray *)array
{
    id<FOXSequence> seq = nil;
    for (id item in [array reverseObjectEnumerator]) {
        seq = [[FOXConcreteSequence alloc] initWithObject:item remainingSequence:seq];
    }
    return seq ?: [[FOXConcreteSequence alloc] init];
}

+ (instancetype)sequenceByRepeatingObject:(id)object times:(NSUInteger)times
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:times];
    for (NSUInteger i = 0; i<times; i++) {
        [array addObject:object];
    }
    return [FOXConcreteSequence sequenceFromArray:array];
}

@end


@implementation FOXSequence (LazyConstructors)

+ (instancetype)lazySequenceFromBlock:(id<FOXSequence>(^)())block
{
    return [[FOXLazySequence alloc] initWithLazyBlock:block];
}

+ (instancetype)lazyUniqueSequence:(id<FOXSequence>)sequence
{
    NSMutableSet *set = [NSMutableSet set];
    return [sequence sequenceByFiltering:^BOOL(id item) {
        if ([set containsObject:item]) {
            return NO;
        } else {
            [set addObject:item ?: [NSNull null]];
            return YES;
        }
    }];
}

@end

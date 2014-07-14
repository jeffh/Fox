#import "PBTAbstractSequence.h"
#import "PBTSequence.h"
#import "PBTLazySequence.h"
#import "PBTConcreteSequence.h"

@interface PBTSequenceEnumerator : NSEnumerator

- (id)initWithSequence:(id<PBTSequence>)sequence;

@property (nonatomic, strong) id<PBTSequence> sequence;

@end

@implementation PBTSequenceEnumerator

- (id)initWithSequence:(id<PBTSequence>)sequence
{
    if (self = [super init]) {
        self.sequence = sequence;
    }
    return self;
}

- (id)nextObject
{
    id result = [self.sequence firstObject];
    self.sequence = [self.sequence remainingSequence];
    return result;
}

@end


@implementation PBTAbstractSequence {
    NSUInteger _cache;
}

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

- (id<PBTSequence>)sequenceByApplyingBlock:(id (^)(id))block
{
    return [[PBTLazySequence alloc] initWithLazyBlock:^id<PBTSequence>{
        id transformedFirstObject = block([self firstObject]);
        id<PBTSequence> transformedRemainingSeq = [[self remainingSequence] sequenceByApplyingBlock:block];
        return [[PBTConcreteSequence alloc] initWithObject:transformedFirstObject
                                         remainingSequence:transformedRemainingSeq];
    }];
}

- (id<PBTSequence>)sequenceFilteredByBlock:(BOOL (^)(id))predicate
{
    return [[PBTLazySequence alloc] initWithLazyBlock:^id<PBTSequence>{
        id<PBTSequence> filteredRemainingSeq = [[self remainingSequence] sequenceFilteredByBlock:predicate];
        if (predicate([self firstObject])) {
            return [[PBTConcreteSequence alloc] initWithObject:[self firstObject]
                                             remainingSequence:filteredRemainingSeq];
        } else {
            return filteredRemainingSeq;
        }
    }];
}

- (id<PBTSequence>)sequenceByConcatenatingSequence:(id<PBTSequence>)sequence {
    NSArray *reversedItems = [[[[self objectEnumerator] allObjects] reverseObjectEnumerator] allObjects];
    id<PBTSequence> seq = sequence;
    for (id item in reversedItems) {
        seq = [[PBTConcreteSequence alloc] initWithObject:item remainingSequence:seq];
    }
    return seq;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])buffer
                                    count:(NSUInteger)len
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

    while (objectsCaptured < len && seq) {
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

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"("];

    NSUInteger count = 0;
    for (id object in self) {
        [description appendFormat:@"%@, ", object];
        if (count++ > 8) {
            [description appendFormat:@"...  "];
            break;
        }
    }

    [description deleteCharactersInRange:NSMakeRange(description.length - 2, 2)];
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

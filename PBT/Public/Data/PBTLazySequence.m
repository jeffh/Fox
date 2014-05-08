#import "PBTLazySequence.h"


@implementation PBTLazySequence {
    PBTLazySequenceBlock _block;
    id _blockValue;
    id<PBTSequence> _sequenceValue;
}

- (instancetype)init
{
    return self = [super init];
}

- (instancetype)initWithLazyBlock:(PBTLazySequenceBlock)block
{
    self = [super init];
    if (self) {
        _block = block;
    }
    return self;
}

- (id)firstObject
{
    return [[self evaluateSequence] firstObject];
}

- (id<PBTSequence>)remainingSequence
{
    return [[self evaluateSequence] remainingSequence];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other
{
    if (![other conformsToProtocol:@protocol(PBTSequence)]) {
        return NO;
    }

    id otherFirstObject = [other firstObject];
    id firstObject = [self firstObject];
    if (firstObject != otherFirstObject && ![firstObject isEqual:otherFirstObject]) {
        return NO;
    }

    id otherRemainingSequence = [other remainingSequence];
    id remainingSequence = [self remainingSequence];
    return remainingSequence == otherRemainingSequence || [remainingSequence isEqual:otherRemainingSequence];
}

- (NSUInteger)hash
{
    return [[self firstObject] hash] ^ [[self remainingSequence] hash];
}

#pragma mark - Private

- (id)evaluateBlock
{
    @synchronized (self) {
        if (_block) {
            _blockValue = _block();
        }
        return _blockValue;
    }
}

- (id<PBTSequence>)evaluateSequence
{
    [self evaluateBlock];
    @synchronized (self) {
        if (_blockValue) {
            id value = _blockValue;
            _blockValue = nil;
            while ([_block isKindOfClass:[PBTLazySequence class]]) {
                value = [value evaluateBlock];
            }
            _sequenceValue = value;
        }
        return _sequenceValue;
    }
}

@end

#import "PBTLazySequence.h"
#import "PBTConcreteSequence.h"

@interface PBTLazySequence ()
@property (nonatomic, copy) PBTLazySequenceBlock block;
@property (nonatomic) id blockValue;
@property (nonatomic) id<PBTSequence> sequenceValue;
@end


@implementation PBTLazySequence

- (instancetype)init
{
    return self = [super init];
}

- (instancetype)initWithLazyBlock:(PBTLazySequenceBlock)block
{
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

#pragma mark - PBTSequence

- (id)firstObject
{
    return [[self evaluateSequence] firstObject];
}

- (id<PBTSequence>)remainingSequence
{
    return [[self evaluateSequence] remainingSequence];
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id [])buffer
                                    count:(NSUInteger)len
{
    const unsigned long firstTimeState = 0;
    const unsigned long processingState = 1;
    if (state->state == firstTimeState) {
        state->mutationsPtr = (__bridge void *)self;
        state->extra[0] = (unsigned long)self;
        state->state = processingState;
    }

    id<PBTSequence> seq = (__bridge id)(void *)(state->extra[0]);
    state->itemsPtr = buffer;

    id object = [seq firstObject];
    state->extra[0] = (unsigned long)[seq remainingSequence];

    if (object) {
        *buffer = object;
        return 1;
    } else {

        return 0;
    }
}

#pragma mark - Private

- (id)evaluateBlock {
    @synchronized (self) {
        if (self.block) {
            self.blockValue = self.block();
            self.block = nil;
        }
        return self.blockValue;
    }
}

- (id<PBTSequence>)evaluateSequence {
    [self evaluateBlock];
    @synchronized (self) {
        if (self.blockValue) {
            id value = self.blockValue;
            self.blockValue = nil;
            while ([self.block isKindOfClass:[PBTLazySequence class]]) {
                value = [value evaluateBlock];
            }
            self.sequenceValue = value;
        }
        return self.sequenceValue;
    }
}

@end

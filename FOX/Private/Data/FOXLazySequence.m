#import "FOXLazySequence.h"
#import "FOXConcreteSequence.h"


@interface FOXLazySequence ()

@property (nonatomic, copy) FOXLazySequenceBlock block;
@property (nonatomic) id blockValue;
@property (nonatomic) id<FOXSequence> sequenceValue;

@end


@implementation FOXLazySequence

- (instancetype)init
{
    return self = [super init];
}

- (instancetype)initWithLazyBlock:(FOXLazySequenceBlock)block
{
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

#pragma mark - FOXSequence

- (id)firstObject
{
    return [[self evaluateSequence] firstObject];
}

- (id<FOXSequence>)remainingSequence
{
    return [[self evaluateSequence] remainingSequence];
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id [])buffer
                                    count:(NSUInteger)len
{
    // lazy sequences are usually recursively lazy, so don't evaluate multiple
    // items in the buffer to avoid potential wasted cycles for evaluations.
    const unsigned long firstTimeState = 0;
    const unsigned long processingState = 1;
    if (state->state == firstTimeState) {
        state->mutationsPtr = (__bridge void *)self;
        state->extra[0] = (unsigned long)self;
        state->state = processingState;
    }

    id<FOXSequence> seq = (__bridge id)(void *)(state->extra[0]);
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

- (id<FOXSequence>)evaluateSequence {
    [self evaluateBlock];
    @synchronized (self) {
        if (self.blockValue) {
            id value = self.blockValue;
            self.blockValue = nil;
            while ([self.block isKindOfClass:[FOXLazySequence class]]) {
                value = [value evaluateBlock];
            }
            self.sequenceValue = value;
        }
        return self.sequenceValue;
    }
}

@end

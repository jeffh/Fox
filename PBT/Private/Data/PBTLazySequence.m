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
        _block = block;
#ifdef DEBUG
//        [self evaluateSequence];
#endif
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
            @autoreleasepool {
                id value = _blockValue;
                _blockValue = nil;
                while ([_block isKindOfClass:[PBTLazySequence class]]) {
                    value = [value evaluateBlock];
                }
                _sequenceValue = value;
            }
        }
        return _sequenceValue;
    }
}

@end

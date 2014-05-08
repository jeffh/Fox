#import "PBTConcreteSequence.h"


@interface PBTConcreteSequence ()

@property (nonatomic) id firstObject;
@property (nonatomic) id<PBTSequence> remainingSequence;

@end


@implementation PBTConcreteSequence

- (instancetype)init
{
    return self = [super init];
}

- (instancetype)initWithObject:(id)object
{
    return [self initWithObject:object remainingSequence:nil];
}

- (instancetype)initWithObject:(id)object
             remainingSequence:(id<PBTSequence>)sequence
{
    self = [super init];
    if (self) {
        self.firstObject = object;
        self.remainingSequence = sequence;
    }
    return self;
}

- (id<PBTSequence>)sequenceWithObjectPrepended:(id)object
{
    return [[[self class] alloc] initWithObject:object remainingSequence:self];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other
{
    if (![other conformsToProtocol:@protocol(PBTSequence)]) {
        return NO;
    }

    id otherFirstObject = [other firstObject];
    if (_firstObject != otherFirstObject && ![_firstObject isEqual:otherFirstObject]) {
        return NO;
    }

    id otherRemainingSequence = [other remainingSequence];
    return _remainingSequence == otherRemainingSequence || [_remainingSequence isEqual:otherRemainingSequence];
}

- (NSUInteger)hash
{
    return [_firstObject hash] ^ [_remainingSequence hash];
}

@end

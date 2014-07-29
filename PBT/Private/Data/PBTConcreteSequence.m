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

@end

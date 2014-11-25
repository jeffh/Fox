#import "FOXConcreteSequence.h"


@interface FOXConcreteSequence ()

@property (nonatomic) id firstObject;
@property (nonatomic) id<FOXSequence> remainingSequence;

@end


@implementation FOXConcreteSequence

- (instancetype)init
{
    if (self = [super init]) {
        _count = 0;
    }
    return self;
}

- (instancetype)initWithObject:(id)object
{
    return [self initWithObject:object remainingSequence:nil];
}

- (instancetype)initWithObject:(id)object
             remainingSequence:(id<FOXSequence>)sequence
{
    self = [super init];
    if (self) {
        self.firstObject = object;
        self.remainingSequence = sequence;
        if (!sequence) {
            _count = 1;
        }
    }
    return self;
}

@end

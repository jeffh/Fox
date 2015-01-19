#import "FOXSequenceRandom.h"

@interface FOXSequenceRandom ()
@property (atomic) id<FOXSequence> sequence;
@end

@implementation FOXSequenceRandom

@synthesize seed; // seed is a no-op

- (instancetype)initWithSequence:(id<FOXSequence>)sequence
{
    self = [super init];
    if (self) {
        self.sequence = sequence;
    }
    return self;
}

- (long long)randomInteger
{
    @synchronized (self) {
        @autoreleasepool {
            NSNumber *result = [self.sequence firstObject];
            self.sequence = [self.sequence remainingSequence];
            return [result longLongValue];
        }
    }
}

- (long long)randomIntegerWithinMinimum:(long long)minimumNumber andMaximum:(long long)maximumNumber
{
    long long number = [self randomInteger];
    long long delta = (maximumNumber + 1) - minimumNumber;
    long long value = 0;
    if (delta) {
        value = (number % delta);
        while (value < minimumNumber) {
            value += delta;
        }
    }
    return value;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithSequence:self.sequence];
}

@end

@implementation FOXSequence (SequenceRandom)

+ (instancetype)lazySequenceFromRandom:(id<FOXRandom>)random
{
    return [FOXSequence lazySequenceFromBlock:^id<FOXSequence>{
        @autoreleasepool {
            return [FOXSequence sequenceWithObject:@([random randomInteger])
                                 remainingSequence:[self lazySequenceFromRandom:random]];
        }
    }];
}

@end

#import "FOXShrinkingIntegerSequence.h"
#import "FOXSequence.h"


@implementation FOXShrinkingIntegerSequence

+ (id<FOXSequence>)sequenceOfNumbersSmallerThan:(NSNumber *)number
{
    if ([number compare:@0] == NSOrderedSame) {
        return nil;
    }

    id<FOXSequence> halves = [self sequenceOfHalvesOfNumber:number];
    id<FOXSequence> result = [halves sequenceByApplyingBlock:^id(NSNumber *value) {
        return @([number longLongValue] - [value longLongValue]);
    }];
    return result;
}

+ (id<FOXSequence>)sequenceOfHalvesOfNumber:(NSNumber *)number
{
    if ([number compare:@0] == NSOrderedSame) {
        return nil;
    }
    id<FOXSequence> remainingSequence = [self sequenceOfHalvesOfNumber:@([number integerValue] / 2)];
    return [FOXSequence sequenceWithObject:number
                         remainingSequence:remainingSequence];
}

@end

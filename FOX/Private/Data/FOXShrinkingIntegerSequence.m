#import "FOXShrinkingIntegerSequence.h"
#import "FOXSequence.h"


@implementation FOXShrinkingIntegerSequence

static NSMutableDictionary *__cache;

+ (void)initialize
{
    [super initialize];
    __cache = [NSMutableDictionary dictionaryWithCapacity:50];
}

+ (id<FOXSequence>)sequenceOfNumbersSmallerThan:(NSNumber *)number
{
    if ([number compare:@0] == NSOrderedSame) {
        return nil;
    }

    id<FOXSequence> result = [__cache objectForKey:number];
    if (result){
        return result;
    }

    id<FOXSequence> halves = [self sequenceOfHalvesOfNumber:number];
    result = [halves sequenceByApplyingBlock:^id(NSNumber *value) {
        return @([number longLongValue] - [value longLongValue]);
    }];
    [__cache setObject:result forKey:number];
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

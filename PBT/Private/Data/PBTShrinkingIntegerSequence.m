#import "PBTShrinkingIntegerSequence.h"
#import "PBTSequence.h"


@implementation PBTShrinkingIntegerSequence

static NSMutableDictionary *__cache;

+ (void)initialize
{
    [super initialize];
    __cache = [NSMutableDictionary dictionaryWithCapacity:50];
}

+ (id<PBTSequence>)sequenceOfNumbersSmallerThan:(NSNumber *)number
{
    if ([number compare:@0] == NSOrderedSame) {
        return nil;
    }

    id<PBTSequence> result = [__cache objectForKey:number];
    if (result){
        return result;
    }

    id<PBTSequence> halves = [self sequenceOfHalvesOfNumber:number];
    result = [halves sequenceByApplyingBlock:^id(NSNumber *value) {
        return @([number longLongValue] - [value longLongValue]);
    }];
    [__cache setObject:result forKey:number];
    return result;
}

+ (id<PBTSequence>)sequenceOfHalvesOfNumber:(NSNumber *)number
{
    if ([number compare:@0] == NSOrderedSame) {
        return nil;
    }
    id<PBTSequence> remainingSequence = [self sequenceOfHalvesOfNumber:@([number integerValue] / 2)];
    return [PBTSequence sequenceWithObject:number
                         remainingSequence:remainingSequence];
}

@end

#import "PBTNumericRoseTree.h"
#import "PBTRoseTree.h"
#import "PBTShrinkingIntegerSequence.h"
#import "PBTSequence.h"


@implementation PBTNumericRoseTree

static NSMutableDictionary *__cache;

+ (void)initialize
{
    [super initialize];
    __cache = [NSMutableDictionary dictionaryWithCapacity:50];
}

+ (PBTRoseTree *)roseTreeWithMaxNumber:(NSNumber *)number
{
    PBTRoseTree *result = [__cache objectForKey:number];

    if (!result) {
        id<PBTSequence> children = [PBTShrinkingIntegerSequence sequenceOfNumbersSmallerThan:number];
        result = [[PBTRoseTree alloc] initWithValue:number
                                         children:[children sequenceByApplyingBlock:^id(NSNumber *value) {
            return [self roseTreeWithMaxNumber:value];
        }]];

        [__cache setObject:result forKey:number];
    }
    return result;
}

@end

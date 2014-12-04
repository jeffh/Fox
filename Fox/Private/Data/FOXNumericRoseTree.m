#import "FOXNumericRoseTree.h"
#import "FOXRoseTree.h"
#import "FOXShrinkingIntegerSequence.h"
#import "FOXSequence.h"


@implementation FOXNumericRoseTree

static NSMutableDictionary *__cache;

+ (void)initialize
{
    [super initialize];
    __cache = [NSMutableDictionary dictionary];
}

+ (FOXRoseTree *)roseTreeWithMaxNumber:(NSNumber *)number
{
    FOXRoseTree *result = [__cache objectForKey:number];
    if (!result) {
        id<FOXSequence> children = [FOXShrinkingIntegerSequence sequenceOfNumbersSmallerThan:number];
        result = [[FOXRoseTree alloc] initWithValue:number
                                         children:[children sequenceByApplyingBlock:^id(NSNumber *value) {
            return [self roseTreeWithMaxNumber:value];
        }]];

        [__cache setObject:result forKey:number];
    }
    return result;
}

@end

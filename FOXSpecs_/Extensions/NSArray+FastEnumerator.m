#import "NSArray+FastEnumerator.h"

@implementation NSArray (FastEnumerator)

+ (instancetype)arrayFromFastEnumerator:(id<NSFastEnumeration>)enumerator
{
    NSMutableArray *items = [NSMutableArray array];
    for (id item in enumerator) {
        [items addObject:item];
    }
    return items;
}

@end

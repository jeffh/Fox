#import "PBTQueue.h"


@interface PBTQueue ()
@property (nonatomic) NSMutableArray *items;
@end


@implementation PBTQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.items = [NSMutableArray array];
    }
    return self;
}

- (void)addObject:(id)object
{
    [self.items addObject:object];
}

- (id)removeObject
{
    id obj = self.items.firstObject;
    [self.items removeObjectAtIndex:0];
    return obj;
}

@end

#import "FOXArraySequence.h"

@interface FOXArraySequence ()
@property (nonatomic) NSArray *array;
@property (nonatomic) NSUInteger offset;
@property (nonatomic) id<FOXSequence> remainingSequence;
@end

@implementation FOXArraySequence

- (instancetype)initWithArray:(NSArray *)array
{
    return [self initWithArray:array offset:0];
}

- (instancetype)initWithArray:(NSArray *)array offset:(NSUInteger)offset
{
    self = [super init];
    if (self) {
        self.offset = offset;
        if (offset < array.count) {
            self.array = array;
            _count = self.array.count - offset;
        }
        if (self.offset + 1 < self.array.count) {
            self.remainingSequence = [[FOXArraySequence alloc] initWithArray:self.array
                                                                      offset:self.offset + 1];
        }

    }
    return self;
}

- (id)firstObject
{
    return [self.array objectAtIndex:self.offset];
}

@end

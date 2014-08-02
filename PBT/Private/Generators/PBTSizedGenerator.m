#import "PBTSizedGenerator.h"


@interface PBTSizedGenerator ()
@property (nonatomic, copy) id<PBTGenerator> (^factory)(NSUInteger size);
@end


@implementation PBTSizedGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithFactory:(id<PBTGenerator> (^)(NSUInteger size))factory;
{
    self = [super init];
    if (self) {
        self.factory = factory;
    }
    return self;
}

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize
{
    return [self.factory(maximumSize) lazyTreeWithRandom:random
                                             maximumSize:maximumSize];
}

@end

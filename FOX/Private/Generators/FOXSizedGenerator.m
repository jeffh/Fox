#import "FOXSizedGenerator.h"


@interface FOXSizedGenerator ()
@property (nonatomic, copy) id<FOXGenerator> (^factory)(NSUInteger size);
@end


@implementation FOXSizedGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithFactory:(id<FOXGenerator> (^)(NSUInteger size))factory;
{
    self = [super init];
    if (self) {
        self.factory = factory;
    }
    return self;
}

- (FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize
{
    return [self.factory(maximumSize) lazyTreeWithRandom:random
                                             maximumSize:maximumSize];
}

@end

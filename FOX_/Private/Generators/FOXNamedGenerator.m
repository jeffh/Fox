#import "FOXNamedGenerator.h"


@interface FOXNamedGenerator ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic) id<FOXGenerator> generator;
@end



@implementation FOXNamedGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithName:(NSString *)name forGenerator:(id<FOXGenerator>)generator
{
    self = [super init];
    if (self) {
        self.name = name;
        self.generator = generator;
    }
    return self;
}

- (FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize
{
    return [_generator lazyTreeWithRandom:random maximumSize:maximumSize];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FOX:%@Generator>", self.name];
}

@end

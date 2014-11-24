#import "PBTNamedGenerator.h"


@interface PBTNamedGenerator ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic) id<PBTGenerator> generator;
@end



@implementation PBTNamedGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithName:(NSString *)name forGenerator:(id<PBTGenerator>)generator
{
    self = [super init];
    if (self) {
        self.name = name;
        self.generator = generator;
    }
    return self;
}

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize
{
    return [_generator lazyTreeWithRandom:random maximumSize:maximumSize];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PBT:%@Generator>", self.name];
}

@end

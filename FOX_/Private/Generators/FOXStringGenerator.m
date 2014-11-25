#import "FOXStringGenerator.h"
#import "FOXCoreGenerators.h"


@interface FOXStringGenerator ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic) id<FOXGenerator> generator;
@property (nonatomic) id<FOXGenerator> stringGenerator;
@end


@implementation FOXStringGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithArrayOfIntegersGenerator:(id<FOXGenerator>)generator
                                            name:(NSString *)name
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
    return [self.stringGenerator lazyTreeWithRandom:random maximumSize:maximumSize];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FOXStringGenerator:%@: %@>", self.name, self.generator];
}

#pragma mark - Properties

- (id<FOXGenerator>)stringGenerator
{
    if (!_stringGenerator) {
        _stringGenerator = FOXMap(self.generator, ^id(NSArray *characters) {
            unichar *buffer = alloca(sizeof(unichar) * characters.count);
            NSUInteger i = 0;
            for (NSNumber *character in characters) {
                buffer[i++] = [character unsignedShortValue];
            }
            return [NSString stringWithCharacters:buffer length:characters.count];
        });
    }
    return _stringGenerator;
}

@end

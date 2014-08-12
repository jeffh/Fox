#import "PBTStringGenerator.h"
#include "PBTCoreGenerators.h"


@interface PBTStringGenerator ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic) id<PBTGenerator> generator;
@property (nonatomic) id<PBTGenerator> stringGenerator;
@end


@implementation PBTStringGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithArrayOfIntegersGenerator:(id<PBTGenerator>)generator
                                            name:(NSString *)name
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
    return [self.stringGenerator lazyTreeWithRandom:random maximumSize:maximumSize];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PBTStringGenerator:%@: %@>", self.name, self.generator];
}

#pragma mark - Properties

- (id<PBTGenerator>)stringGenerator
{
    if (!_stringGenerator) {
        _stringGenerator = PBTMap(self.generator, ^id(NSArray *characters) {
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

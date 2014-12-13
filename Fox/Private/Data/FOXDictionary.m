#import "FOXDictionary.h"
#import "FOXStringUtil.h"

@interface FOXDictionary ()
@property (nonatomic) NSDictionary *backingDictionary;
@end

@implementation FOXDictionary

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [super init];
    if (self) {
        self.backingDictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSString *whitespace = FOXWhitespace(level);
    NSMutableString *result = [NSMutableString string];
    [result appendString:whitespace];
    [result appendString:@"@{\n"];
    for (id key in self) {
        [result appendString:FOXWhitespace(level + 1)];
        [result appendString:FOXDescription(key, level + 1)];
        [result appendString:@": "];
        [result appendString:FOXTrim(FOXDescription(self[key], level + 1))];
        [result appendString:@",\n"];
    }
    [result deleteCharactersInRange:NSMakeRange(result.length - 2, 1)];
    [result appendString:whitespace];
    [result appendString:@"}"];
    return result;

}

- (NSString *)debugDescription {
    return [self description];
}

#pragma mark - NSDictionary

- (NSUInteger)count
{
    return self.backingDictionary.count;
}

- (id)objectForKey:(id)aKey
{
    return [self.backingDictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
    return [self.backingDictionary keyEnumerator];
}

@end

#import "FOXPrettyArray.h"
#import "FOXStringUtil.h"

@interface FOXPrettyArray ()
@property (nonatomic) NSArray *backingArray;
@end

@implementation FOXPrettyArray

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    if (self = [super init]) {
        self.backingArray = [[NSArray alloc] initWithObjects:objects count:cnt];
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    if (self.count == 0) {
        return @"@[]";
    }
    NSString *whitespace = FOXWhitespace(level);
    NSMutableString *result = [NSMutableString string];
    [result appendString:whitespace];
    [result appendString:@"@[\n"];
    for (id item in self) {
        [result appendString:FOXWhitespace(level + 1)];
        [result appendString:FOXTrim(FOXDescription(item, level + 1))];
        [result appendString:@",\n"];
    }
    [result deleteCharactersInRange:NSMakeRange(result.length - 2, 1)];
    [result appendString:whitespace];
    [result appendString:@"]"];
    return result;

}

- (NSString *)debugDescription {
    return [self description];
}

#pragma mark - NSArray

- (id)objectAtIndex:(NSUInteger)index {
    return [self.backingArray objectAtIndex:index];
}

- (NSUInteger)count {
    return self.backingArray.count;
}

@end

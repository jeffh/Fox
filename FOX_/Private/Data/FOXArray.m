#import "FOXArray.h"

@interface FOXArray ()
@property (nonatomic) NSArray *backingArray;
@end

@implementation FOXArray

+ (instancetype)arrayWithArray:(NSArray *)array {
    return [[self alloc] initWithArray:array];
}

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        self.backingArray = array;
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSMutableString *indent = [NSMutableString stringWithFormat:@"  "];
    for (NSUInteger i = 0; i < level; i++) {
        [indent appendString:@" "];
    }

    NSMutableString *result = [NSMutableString stringWithString:@"@[\n"];
    for (id item in self) {
        [result appendFormat:@"%@%@,\n", indent, item];
    }
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

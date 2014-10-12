#import <Foundation/Foundation.h>

// An array that simply provides better description output
@interface PBTArray : NSArray

+ (instancetype)arrayWithArray:(NSArray *)array;
- (instancetype)initWithArray:(NSArray *)array;

@end

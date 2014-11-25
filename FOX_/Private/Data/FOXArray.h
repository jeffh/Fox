#import <Foundation/Foundation.h>

// An array that simply provides better description output
@interface FOXArray : NSArray

+ (instancetype)arrayWithArray:(NSArray *)array;
- (instancetype)initWithArray:(NSArray *)array;

@end

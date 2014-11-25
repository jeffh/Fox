#import <Foundation/Foundation.h>

@interface NSArray (FastEnumerator)

+ (instancetype)arrayFromFastEnumerator:(id<NSFastEnumeration>)enumerator;

@end

#import <Foundation/Foundation.h>

@protocol FOXSequence;

@interface FOXShrinkingIntegerSequence : NSObject

+ (id<FOXSequence>)sequenceOfNumbersSmallerThan:(NSNumber *)number;

@end

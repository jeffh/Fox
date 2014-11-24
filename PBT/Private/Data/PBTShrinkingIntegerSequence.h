#import <Foundation/Foundation.h>

@protocol PBTSequence;

@interface PBTShrinkingIntegerSequence : NSObject

+ (id<PBTSequence>)sequenceOfNumbersSmallerThan:(NSNumber *)number;

@end

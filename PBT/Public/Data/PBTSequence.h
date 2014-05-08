#import <Foundation/Foundation.h>


@protocol PBTSequence <NSObject>

- (id)firstObject;
- (id<PBTSequence>)remainingSequence;

@end

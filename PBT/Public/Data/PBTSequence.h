#import <Foundation/Foundation.h>


@protocol PBTSequence <NSObject, NSFastEnumeration>

- (id)firstObject;
- (id<PBTSequence>)remainingSequence;
- (NSUInteger)count;
- (NSEnumerator *)objectEnumerator;

@end

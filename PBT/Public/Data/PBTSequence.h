#import <Foundation/Foundation.h>

@protocol PBTSequence;

@protocol PBTSequence <NSObject, NSFastEnumeration>

- (id)firstObject;
- (id<PBTSequence>)remainingSequence;
- (NSUInteger)count;

- (NSEnumerator *)objectEnumerator;
- (id<PBTSequence>)sequenceByApplyingBlock:(id(^)(id item))block;
- (id<PBTSequence>)sequenceFilteredByBlock:(BOOL (^)(id item))predicate;
- (id<PBTSequence>)sequenceByConcatenatingSequence:(id<PBTSequence>)sequence;

@end

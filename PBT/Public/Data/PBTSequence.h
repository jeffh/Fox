#import <Foundation/Foundation.h>

@protocol PBTSequence;

@protocol PBTSequence <NSObject, NSFastEnumeration>

- (id)firstObject;
- (id<PBTSequence>)remainingSequence;
- (NSUInteger)count;

- (NSEnumerator *)objectEnumerator;
- (id<PBTSequence>)sequenceByApplyingBlock:(id(^)(id item))block;
- (id<PBTSequence>)sequenceByApplyingIndexedBlock:(id(^)(NSUInteger index, id item))block;
- (id<PBTSequence>)sequenceByApplyingIndexedBlock:(id(^)(NSUInteger index, id item))block startingIndex:(NSUInteger)index;
- (id<PBTSequence>)sequenceFilteredByBlock:(BOOL (^)(id item))predicate;
- (id<PBTSequence>)sequenceByConcatenatingSequence:(id<PBTSequence>)sequence;
- (id<PBTSequence>)sequenceByExcludingIndex:(NSUInteger)index;
- (id)objectByReducingWithSeed:(id)seedObject
                       reducer:(id(^)(id accum, id item))reducer;

@end

// abstract class for sequence implementations.
//
// Behaves like a class cluster, like NSArray or NSDictionary
//
// subclasses must implement these public methods.
// the abstract class will provide convience methods that conforms to the PBTSequence protocol
@interface PBTSequence : NSObject <PBTSequence>

- (id)firstObject;
- (id<PBTSequence>)remainingSequence;

@end

@interface PBTSequence (EagarConstructors)

+ (instancetype)sequence;
+ (instancetype)sequenceWithObject:(id)firstObject;
+ (instancetype)sequenceWithObject:(id)firstObject remainingSequence:(id<PBTSequence>)remainingSequence;
+ (instancetype)sequenceFromArray:(NSArray *)array;

@end

@interface PBTSequence (LazyConstructors)

+ (instancetype)lazySequenceWithInterleavingItemsFromSequences:(NSArray *)sequences;
+ (instancetype)lazySequenceWithByTakingFromSequence:(id<PBTSequence>)sequence maxIndex:(NSUInteger)maxIndex;
+ (instancetype)lazySequenceByConcatenatingSequences:(NSArray *)sequences;
+ (instancetype)lazySequenceFromBlock:(id<PBTSequence>(^)())block;

@end

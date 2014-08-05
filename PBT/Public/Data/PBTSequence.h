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

/*! An abstract class for sequence implementations. Behaves like a class cluster, like NSArray.
 *
 *  The abstract class will provide convience methods that conforms to the PBTSequence protocol
 *  Subclasses must implement the public methods listed below.
 *
 *  The _count ivar is used to cache multiple calls to -[count]. You can set it to explicitly
 *  if the count is known ahead of time instead of having PBTSequence walk all elements.
 *
 *  Whenever possible, this abstract class will produce lazy sequences when conforming to
 *  the PBTSequence protocol.
 */
@interface PBTSequence : NSObject <PBTSequence> {
    NSUInteger _count;
}

- (id)firstObject;
- (id<PBTSequence>)remainingSequence;

@end

/*! Convinence constructors. All these constructors create sequences that are fully realized in
 *  memory upon creation.
 */
@interface PBTSequence (EagarConstructors)

+ (instancetype)sequence;
+ (instancetype)sequenceWithObject:(id)firstObject;
+ (instancetype)sequenceWithObject:(id)firstObject remainingSequence:(id<PBTSequence>)remainingSequence;
+ (instancetype)sequenceFromArray:(NSArray *)array;
+ (instancetype)sequenceByRepeatingObject:(id)object times:(NSUInteger)times;

@end

/*! Convinence constructors. All these constructors create sequences that are lazy -- realized when
 *  needed to avoid large memory allocation.
 */
@interface PBTSequence (LazyConstructors)

+ (instancetype)lazySequenceByConcatenatingSequences:(NSArray *)sequences;
+ (instancetype)lazySequenceFromBlock:(id<PBTSequence>(^)())block;

@end

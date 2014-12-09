#import <Foundation/Foundation.h>

@protocol FOXSequence;

@protocol FOXSequence<NSObject, NSFastEnumeration>

- (id)firstObject;
- (id<FOXSequence>)remainingSequence;

- (NSUInteger)count;
- (NSEnumerator *)objectEnumerator;
- (id<FOXSequence>)sequenceByMapping:(id(^)(id item))block;
- (id<FOXSequence>)sequenceByMappingWithIndex:(id(^)(NSUInteger index, id item))block;
- (id<FOXSequence>)sequenceByMappingWithIndex:(id(^)(NSUInteger index, id item))block startingIndex:(NSUInteger)index;
- (id<FOXSequence>)sequenceByFiltering:(BOOL (^)(id item))predicate;
- (id<FOXSequence>)sequenceByAppending:(id<FOXSequence>)sequence;
- (id<FOXSequence>)sequenceByDroppingIndex:(NSUInteger)index;
- (id)objectByReducingWithSeed:(id)seedObject
                       reducer:(id(^)(id accum, id item))reducer;

@end

/*! An abstract class for sequence implementations. Behaves like a class cluster, like NSArray.
 *
 *  The abstract class will provide convenience methods that conforms to the FOXSequence protocol
 *  Subclasses must implement the public methods listed below.
 *
 *  The _count ivar is used to cache multiple calls to -[count]. You can set it to explicitly
 *  if the count is known ahead of time instead of having FOXSequence walk all elements.
 *
 *  Whenever possible, this abstract class will produce lazy sequences when conforming to
 *  the FOXSequence protocol.
 */
@interface FOXSequence : NSObject <FOXSequence> {
    NSUInteger _count;
}

- (id)firstObject;
- (id<FOXSequence>)remainingSequence;

@end

/*! Convenience constructors. All these constructors create sequences that are fully realized in
 *  memory upon creation.
 */
@interface FOXSequence (EagerConstructors)

+ (instancetype)sequence;
+ (instancetype)sequenceWithObject:(id)firstObject;
+ (instancetype)sequenceWithObject:(id)firstObject remainingSequence:(id<FOXSequence>)remainingSequence;
+ (instancetype)sequenceFromArray:(NSArray *)array;
+ (instancetype)sequenceByRepeatingObject:(id)object times:(NSUInteger)times;

@end

/*! Convenience constructors. All these constructors create sequences that are lazy -- realized when
 *  needed to avoid large memory allocations.
 */
@interface FOXSequence (LazyConstructors)

+ (instancetype)lazySequenceFromBlock:(id<FOXSequence>(^)())block;
+ (instancetype)lazyUniqueSequence:(id<FOXSequence>)sequence;

@end

#import <Foundation/Foundation.h>

@protocol FOXSequence;

@protocol FOXSequence <NSObject, NSFastEnumeration, NSCoding, NSCopying>

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
- (id<FOXSequence>)sequenceByMapcatting:(id<FOXSequence>(^)(id item))block;
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
 *
 *  @warning - If your sequence implementation is significantly different internally, you should
 *             also override NSCoding methods.
 *
 *  Subclasses are assumed to be immutable. For example, the NSCopying implementation,
 *  simply returns self.
 */
@interface FOXSequence : NSObject <FOXSequence> {
    NSUInteger _count;
}

- (id)firstObject;

// object returned should be retained by sequence or objc foreach will
// crash.
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

+ (id<FOXSequence>)lazySequenceFromBlock:(id<FOXSequence>(^)())block;
+ (id<FOXSequence>)lazyUniqueSequence:(id<FOXSequence>)sequence;
+ (id<FOXSequence>)lazyRangeStartingAt:(NSInteger)startIndex endingBefore:(NSUInteger)endIndex;
+ (id<FOXSequence>)subsetsOfSequence:(id<FOXSequence>)sequence;
+ (id<FOXSequence>)combinationsOfSequence:(id<FOXSequence>)sequence size:(NSUInteger)size;

@end

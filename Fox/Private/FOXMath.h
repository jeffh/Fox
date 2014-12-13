#import "FOXMacros.h"

@protocol FOXRandom;

/// Combination algorithm that performs no heap memory allocations
/// produces indicies of combinations for a given numericSize.
///
/// If the block returns NO, stops the permutation loop.
FOX_EXPORT void eachCombination(NSUInteger numericSize, NSUInteger combinationSize, void(^processor)(NSUInteger *combination, NSUInteger size));

/// permutation algorithm that performs no heap memory allocations.
/// mutates items array to produce each permutation.
///
/// If the block returns NO, stops the permutation loop.
FOX_EXPORT void eachPermutation(NSMutableArray *items, BOOL(^processor)(NSArray *permutation));

FOX_EXPORT void foreverRandom(NSArray *items, id<FOXRandom> random, BOOL(^processor)(id item));

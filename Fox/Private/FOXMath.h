#import <Foundation/Foundation.h>

/// Combination algorithm that performs no heap memory allocations
/// produces indicies of combinations for a given numericSize.
void eachCombination(NSUInteger numericSize, NSUInteger combinationSize, void(^processor)(NSUInteger *combination, NSUInteger size));

/// permutation algorithm that performs no heap memory allocations.
/// mutates items array to produce each permutation.
void eachPermutation(NSMutableArray *items, BOOL(^processor)(NSArray *permutation));


#import <Foundation/Foundation.h>


@protocol FOXSequence;
@class FOXRoseTree;


/*! A rose tree data structure. Generators return these lazy trees which allows "shrinking" of
 *  a given value by walking its children.
 *
 *  Like sequences, rose trees support operations to derive new lazy rose trees from existing ones.
 */
@interface FOXRoseTree : NSObject

/*! The value that this tree holds. Smaller variants of this value are in this tree's children.
 */
@property (nonatomic) id value;

/*! Children always returns a sequence, even if set to nil.
 */
@property (nonatomic) id<FOXSequence> children; // of FOXRoseTrees

/*! Generates a lazy sequence of rose tree permutations. A permutation is where one of the given
 *  rose trees is replaced by one of its children.
 *
 *  The pseudocode is as follows:
 *
 *  permutations = []
 *  foreach (index, roseTree) in roseTrees {
 *      foreach (_, child) in roseTree.children {
 *          permutation = roseTrees.copy()
 *          permutation[index] = roseTree
 *          permutations.add(permutation)
 *      }
 *  }
 *  return permutations
 *
 *  @param roseTrees an array of rose trees to generate permutations
 *  @returns a sequence of sequence of rose trees.
 *
 */
+ (id<FOXSequence>)permutationsOfRoseTrees:(NSArray *)roseTrees;

/*! Generates all possible permutations of tree merging and shrinking. This uses behavior from
 *  +[permutationsOfRoseTrees:] as well as dropping one of the given rose trees.
 *
 *  Use this method recursively to generate all possible shrinkings of a collection of rose trees.
 *
 *  @see FOXArrayOfSize
 *
 *  @returns a sequence of rose trees.
 */
+ (id<FOXSequence>)sequenceByExpandingRoseTrees:(NSArray *)roseTrees;

/*! Recursively creates a rose tree using arrays as a short-hand.
 *
 *  Each rose tree must be exactly two-elements long and in the form:
 *
 *     @[<value>, <children>]
 *
 *  where <children> is an array of rose trees in the same array-literal form.
 *
 *  This is mostly useful for creating deep rose trees in tests.
 */
+ (instancetype)treeFromArray:(NSArray *)roseTreeLiteral;

/*! Flattens a two-dimensional rose tree into a one-dimensional rose tree.
 */
+ (instancetype)joinedTreeFromNestedRoseTree:(FOXRoseTree *)roseTree;

/*! Merges rose trees and provides shrinking from all the merged results. The returned rose tree
 *  will contain arrays from all/some of the values in roseTrees.
 *
 *  If you prefer the returned values not shrink in size, use +[zipTreeFromRoseTrees:] instead.
 *
 *  @see FOXArrayOfSize
 */
+ (instancetype)shrinkTreeFromRoseTrees:(NSArray *)roseTrees;

/*! Merges rose trees and provides shrinking from all the merged results. This returned rose tree
 *  will contain arrays from all of the values in the roseTrees.
 *
 *  If you prefer the return values to shrink in size, use +[shrinkTreeFromRoseTrees:] instead.
 *
 *  @see FOXTupleOfGenerators
 */
+ (instancetype)zipTreeFromRoseTrees:(NSArray *)roseTrees;

/*! Creates a "pure" rose tree, containing only one value with no possible smaller values.
 */
- (instancetype)initWithValue:(id)value;

/*! Creates a rose tree with a value and children (possible smaller values).
 *
 *  Due to the potential large size of rose trees, it's recommended to have children be a lazy
 *  sequence.
 */
- (instancetype)initWithValue:(id)value children:(id<FOXSequence>)children;

/*! Creates a new rose tree by applying the block to each node's value inside the rose tree.
 */
- (instancetype)treeByApplyingBlock:(id(^)(id element))block;

/*! Creates a new rose tree by filtering smaller values with the given block.
 *
 *  @notice this will NOT call the block on the current (largest) value.
 */
- (instancetype)treeFilterChildrenByBlock:(BOOL(^)(id element))block;

@end

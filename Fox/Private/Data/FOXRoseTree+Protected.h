#import "FOXRoseTree.h"

@interface FOXRoseTree (Protected)

/*! Frees all internal data the rose tree stores. Similar to calling -[dealloc].
 *
 *  This can be used when traversing the rose tree to eliminate memory spikes
 *  at the expense of complexity to sure the rose tree isn't used afterwards.
 *
 *  @warning Mutates an "immutable" data structure.
 */
- (void)freeInternals;

/*! Mutates the rose tree with the given block.
 *
 *  This can be used to eliminate memory spikes at the expense of complexity to
 *  sure mutation is kept local (by convention).
 *
 *  @warning Mutates an "immutable" data structure.
 */
- (void)mutateTreeByApplyingBlock:(id(^)(id element))block;

@end

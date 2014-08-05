#import <Foundation/Foundation.h>


@protocol PBTSequence;
@class PBTRoseTree;


@interface PBTRoseTree : NSObject

@property (nonatomic) id value;

/*! Children always returns an id<PBTSequence> object, even if set
 *  to nil.
 */
@property (nonatomic) id<PBTSequence> children; // of PBTRoseTrees

+ (id<PBTSequence>)permutationsOfRoseTrees:(NSArray *)roseTrees;
+ (id<PBTSequence>)sequenceByExpandingRoseTrees:(NSArray *)roseTrees;

+ (instancetype)treeFromArray:(NSArray *)roseTreeLiteral;
+ (instancetype)joinedTreeFromNestedRoseTree:(PBTRoseTree *)roseTree;
+ (instancetype)shrinkTreeFromRoseTrees:(NSArray *)roseTrees merger:(id(^)(NSArray *values))merger;
+ (instancetype)zipTreeFromRoseTrees:(NSArray *)roseTrees byApplying:(id(^)(NSArray *values))block;

- (instancetype)initWithValue:(id)value;
- (instancetype)initWithValue:(id)value children:(id<PBTSequence>)children;

- (PBTRoseTree *)treeByApplyingBlock:(id(^)(id element))block;
- (PBTRoseTree *)treeFilterChildrenByBlock:(BOOL(^)(id element))block;
- (PBTRoseTree *)treeFilterByBlock:(BOOL(^)(id element))block;

- (NSArray *)array;

@end

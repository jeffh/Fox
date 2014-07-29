#import <Foundation/Foundation.h>


@protocol PBTSequence;
@class PBTRoseTree;


@interface PBTRoseTree : NSObject

@property (nonatomic) id value;

/*! Children always returns an id<PBTSequence> object, even if set
 *  to nil.
 */
@property (nonatomic) id<PBTSequence> children; // of PBTRoseTrees

+ (instancetype)treeFromArray:(NSArray *)roseTreeLiteral;
+ (instancetype)mergedTreeFromRoseTrees:(NSArray *)roseTrees merger:(id(^)(NSArray *values))merger;
- (instancetype)initWithValue:(id)value;
- (instancetype)initWithValue:(id)value children:(id<PBTSequence>)children;

- (PBTRoseTree *)treeByApplyingBlock:(id(^)(id element))block;
- (PBTRoseTree *)treeFilteredByBlock:(BOOL(^)(id element))block;

- (NSArray *)array;

@end

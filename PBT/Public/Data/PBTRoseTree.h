#import <Foundation/Foundation.h>


@protocol PBTSequence;
@class PBTRoseTree;


@interface PBTRoseTree : NSObject

@property (nonatomic) id value;
@property (nonatomic) id<PBTSequence> children; // of PBTRoseTrees

+ (instancetype)treeFromArray:(NSArray *)roseTreeLiteral;
- (instancetype)initWithValue:(id)value;
- (instancetype)initWithValue:(id)value children:(id<PBTSequence>)children;

- (PBTRoseTree *)treeByApplyingBlock:(id(^)(id element))block;
- (PBTRoseTree *)treeFilteredByBlock:(BOOL(^)(id element))block;

- (NSArray *)array;

@end

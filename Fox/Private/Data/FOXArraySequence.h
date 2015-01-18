#import "FOXSequence.h"

/// Exists mostly to reduce memory footprint.
@interface FOXArraySequence : FOXSequence

- (instancetype)initWithArray:(NSArray *)array;
- (instancetype)initWithArray:(NSArray *)array offset:(NSUInteger)offset;

@end

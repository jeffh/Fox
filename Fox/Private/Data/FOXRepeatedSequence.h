#import "FOXSequence.h"

/// Exists mostly to reduce memory footprint.
@interface FOXRepeatedSequence : FOXSequence

- (instancetype)initWithObject:(id)object times:(NSUInteger)times;

@end

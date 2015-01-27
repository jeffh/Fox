#import "FOXMacros.h"

@protocol FOXObjectiveCRepresentation <NSObject>

- (NSString *)objectiveCStringRepresentation;

@end

/*! Internal Debugging Tool. Useful to make certain Fox data structures
 *  Dump an objective-c compatible representation.
 */
FOX_EXPORT NSString *FOXRepr(id obj);

#import <Foundation/Foundation.h>

#define FOX_EXPORT FOUNDATION_EXPORT
#define FOX_INLINE NS_INLINE
#define FOX_EXTERN FOUNDATION_EXTERN

// Marks ALPHA APIs. Alpha APIs can change between versions.
#define FOX_ALPHA_API

// Weakly deprecated. Usually indicated for APIs that might be replaced
// by alpha APIs. Users of Fox should ignore this, since this may not result
// in a deprecation in future versions.
//
// No compiler warning emitted.
#define FOX_WEAK_DEPRECATED(s)

// Add actual deprecation warning. Scheduled for removal.
// Specify the major version of removal, eg - "Will remove in Fox v3.x.x.".
#define FOX_DEPRECATED(s) DEPRECATED_MSG_ATTRIBUTE(s)

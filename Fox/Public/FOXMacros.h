#import <Foundation/Foundation.h>

#define FOX_UNYIELDABLE __attribute__(annotate("net.jeffhui.fox.unyieldable"))
#define FOX_EXPORT FOUNDATION_EXPORT
#define FOX_INLINE NS_INLINE
#define FOX_EXTERN FOUNDATION_EXTERN
#define FOX_DEPRECATED(s) DEPRECATED_MSG_ATTRIBUTE(s)

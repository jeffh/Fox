#import "FOXMacros.h"
#import <stdio.h>

FOX_EXPORT void *FOXCalloc(size_t size1, size_t size2);
FOX_EXPORT void *FOXMalloc(size_t size);
FOX_EXPORT void *FOXRealloc(void *oldPtr, size_t size);
FOX_EXPORT char *FOXCStringOnHeap(char *fmt, ...);

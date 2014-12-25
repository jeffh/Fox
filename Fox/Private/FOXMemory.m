#import "FOXMemory.h"

void *FOXCalloc(size_t size1, size_t size2) {
    void *ptr = calloc(size1, size2);
    if (ptr == NULL) {
        fprintf(stderr, "calloc(%lu, %lu) failed\n", size1, size2);
        exit(1);
    }
    return ptr;
}

void *FOXMalloc(size_t size) {
    void *ptr = malloc(size);
    if (ptr == NULL) {
        fprintf(stderr, "malloc(%lu) failed\n", size);
        exit(1);
    }
    return ptr;
}

void *FOXRealloc(void *oldPtr, size_t size) {
    void *ptr = realloc(oldPtr, size);
    if (ptr == NULL) {
        fprintf(stderr, "realloc(%p, %lu) failed\n", oldPtr, size);
        exit(1);
    }
    return ptr;
}

FOX_EXPORT char *FOXCStringOnHeap(char *fmt, ...) {
    char *str_clone = FOXCalloc((strlen(fmt) + 20), sizeof(char));
    va_list args;
    va_start(args, fmt);
    vsprintf(str_clone, fmt, args);
    va_end(args);
    return str_clone;
}

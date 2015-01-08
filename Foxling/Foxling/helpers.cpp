#include "helpers.h"

using namespace llvm;

bool Foxling::isConstantExpression(const Stmt *stmt) {
    return (dyn_cast_or_null<StringLiteral>(stmt) ||
            dyn_cast_or_null<IntegerLiteral>(stmt) ||
            dyn_cast_or_null<CharacterLiteral>(stmt) ||
            dyn_cast_or_null<FloatingLiteral>(stmt) ||
            dyn_cast_or_null<ImaginaryLiteral>(stmt) ||
            dyn_cast_or_null<CompoundLiteralExpr>(stmt));
}

void *Foxling::allocate(size_t size) {
    void *ptr = malloc(size);
    if (ptr == nullptr) {
        fprintf(stderr, "Failed to allocate memory\n");
        abort();
    }
    return ptr;
}

int Foxling::allocate_sprintf(char **ptr, const char *format, ...) {
    va_list argsForSize;
    va_start(argsForSize, format);
    va_list argsForString;
    va_copy(argsForString, argsForSize);
    size_t size = vsnprintf(NULL, 0, format, argsForSize) + 1;
    va_end(argsForSize);

    *ptr = (char *)allocate(size);
    int result = vsnprintf(*ptr, size, format, argsForString);
    
    va_end(argsForString);
    return result;
}

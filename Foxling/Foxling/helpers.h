#ifndef __Foxling__helpers__
#define __Foxling__helpers__

#include "clang/AST/AST.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "Rewriter.h"

namespace Foxling {
    /// Returns true if the given Stmt is a constant expression
    bool isConstantExpression(const clang::Stmt *stmt);

    void *allocate(size_t size);
    int allocate_sprintf(char **ptr, const char *format, ...);
}

#endif /* defined(__Foxling__helpers__) */

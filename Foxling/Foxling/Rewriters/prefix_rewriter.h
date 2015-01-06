#ifndef __Foxling__prefix_rewriter__
#define __Foxling__prefix_rewriter__

#include "clang/AST/AST.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
//#include "clang/Rewrite/Core/Rewriter.h"
#include "Rewriter.h"

namespace Foxling {

    using namespace clang;
    using namespace clang::ast_matchers;

    /// Inserts contents to the top of the source
    void prefixTranslationUnit(ASTContext &Context,
                               Rewriter &Rewrite,
                               StringRef contentsToInsert);
}

#endif /* defined(__Foxling__prefix_rewriter__) */

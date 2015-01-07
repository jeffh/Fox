#ifndef __Foxling__objc_matchers__
#define __Foxling__objc_matchers__

#include <stdio.h>
#include "clang/ASTMatchers/ASTMatchers.h"
#include "clang/AST/AST.h"

namespace Foxling {
    using namespace clang;
    using namespace clang::ast_matchers;

    const internal::VariadicDynCastAllOfMatcher<Stmt, ObjCMessageExpr> objCMessageExpr;
    const internal::VariadicDynCastAllOfMatcher<Stmt, ObjCPropertyRefExpr> objCPropertyRefExpr;
    const internal::VariadicDynCastAllOfMatcher<Stmt, ObjCAtTryStmt> objCAtTryStmt;
    const internal::VariadicDynCastAllOfMatcher<Stmt, ObjCAtSynchronizedStmt> objCAtSynchronizedStmt;
    const internal::VariadicDynCastAllOfMatcher<Stmt, ObjCForCollectionStmt> objCForCollectionStmt;
    const internal::VariadicDynCastAllOfMatcher<Stmt, ObjCAutoreleasePoolStmt> objCAutoreleasePoolStmt;
    const internal::VariadicDynCastAllOfMatcher<Decl, ObjCImplDecl> objCImplDecl;
    const internal::VariadicDynCastAllOfMatcher<Decl, ObjCCategoryImplDecl> objCCategoryImplDecl;
}

#endif /* defined(__Foxling__objc_matchers__) */

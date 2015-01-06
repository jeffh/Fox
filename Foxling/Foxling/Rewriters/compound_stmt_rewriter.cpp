#include "compound_stmt_rewriter.h"

bool Foxling::isYieldCallExpr(const CallExpr *callExpr) {
    if (const ImplicitCastExpr *castExpr = dyn_cast_or_null<ImplicitCastExpr>(callExpr->getCallee())) {
        if (const DeclRefExpr *declRefExpr = dyn_cast_or_null<DeclRefExpr>(castExpr->getSubExpr())) {
            if (const NamedDecl *namedDecl = dyn_cast_or_null<NamedDecl>(declRefExpr->getDecl())) {
                if (namedDecl->getNameAsString() == "fthread_yield") {
                    return true;
                }
            }
        }
    }
    return false;
}

void Foxling::CompoundStmtRewriter::run(const MatchFinder::MatchResult &Result) {
    if (const CompoundStmt *stmts = Result.Nodes.getNodeAs<CompoundStmt>("stmts")) {
        for (auto it = stmts->body_begin(); it != stmts->body_end(); it++) {
            Stmt *stmt = *it;
            if (const CallExpr *callExpr = dyn_cast_or_null<CallExpr>(stmt)) {
                if (isYieldCallExpr(callExpr)) {
                    continue;
                }
            }
            Rewrite.InsertText(stmt->getLocStart(), Inject + " ");
        }
    }
}

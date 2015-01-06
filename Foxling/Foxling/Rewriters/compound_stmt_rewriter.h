#ifndef __Foxling__compound_stmt_rewriter__
#define __Foxling__compound_stmt_rewriter__

#include "clang/AST/AST.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "source_rewriter.h"

namespace Foxling {
    using namespace clang;
    using namespace clang::ast_matchers;

    /// Returns true if the given callExpr is the yield statement:
    /// fthread_yield();
    ///
    bool isYieldCallExpr(const CallExpr *callExpr);

    /// Rewrites compound statements by interleaving yield statements:
    /// {
    ///   int b;
    ///   b = a();
    ///   return 2 + b;
    /// } => {
    ///   fthread_yield();
    ///   int b;
    ///   fthread_yield();
    ///   b = a();
    ///   fthread_yield();
    ///   return 2 + b;
    /// }
    ///
    /// Note that it does not conform to traditional C89 specifications that
    /// requires local variables to be declared before any other statements.
    /// (But C99 removes that limitation).
    ///
    ///
    class CompoundStmtRewriter : public MatchFinder::MatchCallback {
    public:
        CompoundStmtRewriter(SourceRewriter &r, std::string inject) : Rewrite(r), Inject(inject) {}

        void run(const MatchFinder::MatchResult &Result);
    private:
        std::string Inject;
        SourceRewriter &Rewrite;
    };
}

#endif /* defined(__Foxling__compound_stmt_rewriter__) */

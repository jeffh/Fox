#ifndef __Foxling__unary_rewriter__
#define __Foxling__unary_rewriter__

#include "clang/AST/AST.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "source_rewriter.h"

namespace Foxling {

    using namespace clang;
    using namespace clang::ast_matchers;

    /// Rewrites unary operators add a yield in between read and writes:
    /// ++variable => {
    ///     __typeof(variable) __a = variable;
    ///     fthread_yield();
    ///     variable = ++__a;
    /// }
    ///
    /// variable++ => {
    ///     __typeof(variable) __a = variable;
    ///     fthread_yield();
    ///     variable = ++__a;
    /// }
    ///
    /// Does not rewrite constant expressions (eg - ~0x34) or memory-related
    /// unary operations (& and *)
    ///
    /// If the unary is overloaded, we'll have problems...
    class UnaryRewriter : public MatchFinder::MatchCallback {
    public:
        UnaryRewriter(SourceRewriter &r, std::string code, ASTContext &c)
        : Rewrite(r), InjectCode(code), Context(c) {}

        void run(const MatchFinder::MatchResult &Result);
    protected:
        bool shouldEmitResult(const UnaryOperator *op) const;
    private:
        ASTContext &Context;
        std::string InjectCode;
        SourceRewriter &Rewrite;
    };
}

#endif /* defined(__Foxling__unary_rewriter__) */

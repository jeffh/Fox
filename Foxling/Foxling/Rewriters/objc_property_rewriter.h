#ifndef __Foxling__objc_property_rewriter__
#define __Foxling__objc_property_rewriter__

#include "clang/AST/AST.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "source_rewriter.h"

namespace Foxling {

    using namespace clang;
    using namespace clang::ast_matchers;

    /// Rewrites literal objc property accesses to add a yield.
    /// obj.p1 = foo => obj.p1 = {
    ///   id __receiver = foo;
    ///   fthread_yield();
    ///   __receiver;
    /// }.p1
    ///
    /// obj.p1 = 2 => obj.p1 = 2; (unchanged)
    ///
    /// Does not yield for getters. Message send does this.

    class ObjCPropertyRewriter : public MatchFinder::MatchCallback {
    public:
        ObjCPropertyRewriter(SourceRewriter &r, std::string code, std::string key)
        : Rewrite(r), InjectCode(code), BindKey(key) {}

        void run(const MatchFinder::MatchResult &Result);
    private:
        SourceRewriter &Rewrite;
        std::string InjectCode;
        std::string BindKey;
    };
    
}
#endif /* defined(__Foxling__objc_property_rewriter__) */

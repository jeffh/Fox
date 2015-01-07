#ifndef __Foxling__objc_property_rewriter__
#define __Foxling__objc_property_rewriter__

#include "clang/AST/AST.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "source_rewriter.h"

namespace Foxling {

    using namespace clang;
    using namespace clang::ast_matchers;

    /// Rewrites literal objc property accesses to add a yield.
    /// obj.p1 => {
    ///   id __receiver = obj;
    ///   fthread_yield();
    ///   __receiver;
    /// }.p1
    ///
    /// obj.p1.p2 => {
    ///   __typeof(..) __receiver = {
    ///      fthread_yield();
    ///      obj;
    ///   }.p1
    ///   fthread_yield();
    ///   __receiver;
    /// }.p2
    ///
    /// obj.p1 = 2 => fthread_yield(); obj.p1 = 2;
    ///
    /// Does not yield in self calls: eg - self.foo

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

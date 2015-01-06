#ifndef __Foxling__objc_message_rewriter__
#define __Foxling__objc_message_rewriter__

#include "clang/AST/AST.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include <vector>
#include <algorithm>
#include "source_rewriter.h"

namespace Foxling {

    using namespace clang;
    using namespace clang::ast_matchers;


    /// Rewrites literal objc message sends to add a yield.
    /// [obj msg]; => {
    ///   id __receiver = obj;
    ///   fthread_yield();
    ///   [__receiver msg];
    /// };
    ///
    /// Property accesses are IGNORED for this rewriter
    class ObjCMessageRewriter : public MatchFinder::MatchCallback {
    public:
        ObjCMessageRewriter(SourceRewriter &r, std::string code)
        : Rewrite(r), InjectCode(code) {}

        void run(const MatchFinder::MatchResult &Result);
    private:
        std::string InjectCode;
        SourceRewriter &Rewrite;
    };

}

#endif /* defined(__Foxling__objc_message_rewriter__) */

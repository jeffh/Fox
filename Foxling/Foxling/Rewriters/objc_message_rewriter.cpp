#include "objc_message_rewriter.h"
#include "helpers.h"

void Foxling::ObjCMessageRewriter::run(const MatchFinder::MatchResult &Result) {
    if (const ObjCMessageExpr *msgExpr = Result.Nodes.getNodeAs<ObjCMessageExpr>(BindKey)) {
        // don't insert yields for property accesses to self
        SourceRange receiverRange = msgExpr->getReceiverRange();
        if (receiverRange.getBegin() != receiverRange.getEnd()) {
            std::string receiverExprStr = msgExpr->getReceiverType().getAsString();
            char *str;
            allocate_sprintf(&str, "({ %s __receiver__%lu = ",
                             receiverExprStr.c_str(),
                             (uintptr_t)msgExpr);
            Rewrite.InsertText(receiverRange.getBegin(), str);
            free(str);
            allocate_sprintf(&str, "; %s __receiver__%lu; })",
                             InjectCode.c_str(),
                             (uintptr_t)msgExpr);
            Rewrite.InsertTextAfterToken(receiverRange.getEnd(), str);
            free(str);
        }
    }
}

#include "objc_message_rewriter.h"

void Foxling::ObjCMessageRewriter::run(const MatchFinder::MatchResult &Result) {
    if (const ObjCMessageExpr *msgExpr = Result.Nodes.getNodeAs<ObjCMessageExpr>(BindKey)) {
        // don't insert for property accesses that are zero-sized expressions.
        SourceRange receiverRange = msgExpr->getReceiverRange();
        if (receiverRange.getBegin() != receiverRange.getEnd()) {
            std::string receiverExprStr = msgExpr->getReceiverType().getAsString();
            char stra[500]; // TODO: allocate memory
            memset(stra, 0, sizeof(stra));
            sprintf(stra, "({ %s __receiver__%lu = ",
                    receiverExprStr.c_str(),
                    (uintptr_t)msgExpr);
            Rewrite.InsertText(receiverRange.getBegin(), stra);
            char strb[500]; // TODO: allocate memory
            memset(strb, 0, sizeof(stra));
            sprintf(strb, "; %s __receiver__%lu; })",
                    InjectCode.c_str(),
                    (uintptr_t)msgExpr);
            Rewrite.InsertTextAfterToken(receiverRange.getEnd(), strb);
        }
    }
}

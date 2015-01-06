#include "objc_property_rewriter.h"

void Foxling::ObjCPropertyRewriter::run(const MatchFinder::MatchResult &Result) {
    if (const ObjCPropertyRefExpr *propertyExpr = Result.Nodes.getNodeAs<ObjCPropertyRefExpr>("expr")) {
        if (propertyExpr->isMessagingGetter()) {
//            llvm::outs() << "OriGet: " << Rewrite.getUnderlyingRewrittenText(propertyExpr->getSourceRange()) << "\n";
            auto baseExprType = propertyExpr->getBase()->getType().getAsString();
            char str[500]; // TODO: allocate memory
            memset(str, 0, sizeof(str));
            sprintf(str, "({ %s __receiver__%lu = ",
                    baseExprType.c_str(),
                    (uintptr_t)propertyExpr);
            Rewrite.RemoveText(propertyExpr->getLocEnd().getLocWithOffset(-1), 1);
            Rewrite.InsertText(propertyExpr->getLocStart(), str);
            sprintf(str, "; %s __receiver__%lu; }).",
                    InjectCode.c_str(),
                    (uintptr_t)propertyExpr);
            Rewrite.InsertText(propertyExpr->getLocEnd(), str);
        }
    }
}

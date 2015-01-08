#include "objc_property_rewriter.h"
#include "clang/AST/AST.h"
#include "helpers.h"

using namespace llvm;

void Foxling::ObjCPropertyRewriter::run(const MatchFinder::MatchResult &Result) {
    if (const ObjCPropertyRefExpr *propertyExpr = Result.Nodes.getNodeAs<ObjCPropertyRefExpr>(BindKey)) {
        if (propertyExpr->isMessagingGetter()) {
            // no op. Multiple dot-accesses seem to be also
            // match as message send expressions.
        } else if (propertyExpr->isMessagingSetter()) {
            auto start = propertyExpr->child_begin();
            std::advance(start, 3); // seems like a bad idea

            // don't insert yield inside constant expr
            if (!isConstantExpression(*start)) {
                auto exprType = propertyExpr->getSetterArgType().getAsString();
                char *str;
                allocate_sprintf(&str, "({ %s __prop_receiver__%lu = ",
                                 exprType.c_str(),
                                 (uintptr_t)propertyExpr);
                Rewrite.InsertText(start->getLocStart(), str);
                free(str);
                
                allocate_sprintf(&str, "; %s __prop_receiver__%lu; })",
                                 InjectCode.c_str(),
                                 (uintptr_t)propertyExpr);
                Rewrite.InsertTextAfterToken(start->getLocEnd(), str);
                free(str);
            }
        }
    }
}

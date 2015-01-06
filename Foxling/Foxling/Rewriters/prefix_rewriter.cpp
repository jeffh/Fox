#include "prefix_rewriter.h"

void Foxling::prefixTranslationUnit(ASTContext &Context,
                                    Rewriter &Rewrite,
                                    StringRef contentsToInsert) {
    SourceLocation loc = Context.getSourceManager().getLocForStartOfFile(Context.getSourceManager().getMainFileID());
    Rewrite.InsertText(loc, contentsToInsert);
}

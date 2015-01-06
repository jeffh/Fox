#ifndef __Foxling__source_rewriter__
#define __Foxling__source_rewriter__

#include "clang/AST/AST.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
//#include "clang/Rewrite/Core/Rewriter.h"
#include "clang/Lex/Lexer.h"
#include <vector>
#include <algorithm>
#include <string>
#include "Rewriter.h"

namespace Foxling {
    using namespace clang;
    using namespace clang::ast_matchers;

    inline bool operator<=(const SourceLocation &LHS, const SourceLocation &RHS) {
        return LHS < RHS || LHS == RHS;
    }

    struct ReplacementEntry {
        SourceRange replaceRange;
        std::string insertedText;

        int getSizeDelta(SourceManager &SourceMgr) const {
            unsigned end = SourceMgr.getFileOffset(replaceRange.getEnd());
            unsigned begin = SourceMgr.getFileOffset(replaceRange.getBegin());
            return (int)insertedText.size() - (int)(end - begin);
        }

        bool intersectsRange(SourceRange Range) const {
            return ((Range.getBegin() <= replaceRange.getBegin() &&
                    replaceRange.getEnd() <= Range.getEnd()) ||
                    (replaceRange.getBegin() <= Range.getBegin() &&
                     Range.getEnd() <= replaceRange.getEnd()));
        }
    };

    class SourceRewriter {
        std::vector<ReplacementEntry> Replacements;
        Rewriter &Rewrite;
    public:
        SourceRewriter(Rewriter &r) : Rewrite(r) {}

    protected:
        void recordChange(SourceRange range, StringRef Str) {
            Replacements.push_back((ReplacementEntry){range, Str});
        }

        unsigned getLocationOffsetAndFileID(SourceLocation Loc,
                                            FileID &FID) const;

        int getOffsetToAdjustLoc(SourceLocation Loc) const;

        SourceLocation getAdjustedLoc(SourceLocation Loc) const {
            return Loc.getLocWithOffset(getOffsetToAdjustLoc(Loc));
        }

        SourceRange getAdjustedRange(SourceRange Range) const;

    public:
        std::string getRewrittenText(SourceRange Range) const;
        std::string getUnderlyingRewrittenText(SourceRange Range) const {
            return Rewrite.getRewrittenText(Range);
        }

        SourceManager &getSourceMgr() const {
            return Rewrite.getSourceMgr();
        }

        bool RemoveText(SourceLocation Loc, unsigned Length) {
            recordChange(SourceRange(Loc, Loc.getLocWithOffset(Length)), "");
            return Rewrite.RemoveText(Loc, Length);
        }

        bool InsertText(SourceLocation Loc, StringRef Str) {
            recordChange(SourceRange(Loc), Str);
            return Rewrite.InsertText(Loc, Str);
        }

        bool InsertTextAfterToken(SourceLocation Loc, StringRef Str) {
            recordChange(SourceRange(Loc), Str);
            return Rewrite.InsertTextAfterToken(Loc, Str);
        }
    };
}

#endif /* defined(__Foxling__source_rewriter__) */

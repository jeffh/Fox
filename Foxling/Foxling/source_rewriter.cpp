#include "source_rewriter.h"

using namespace Foxling;


unsigned SourceRewriter::getLocationOffsetAndFileID(SourceLocation Loc,
                                                    FileID &FID) const {
    assert(Loc.isValid() && "Invalid location");
    std::pair<FileID,unsigned> V = Rewrite.getSourceMgr().getDecomposedLoc(Loc);
    FID = V.first;
    return V.second;
}

int SourceRewriter::getOffsetToAdjustLoc(SourceLocation Loc) const {
    int totalOffset = 0;
    for (auto it = Replacements.begin(); it != Replacements.end(); it++) {
        unsigned offset = Rewrite.getSourceMgr().getFileOffset(Loc);
        unsigned itOffset = Rewrite.getSourceMgr().getFileOffset(it->replaceRange.getEnd());
        if (offset < itOffset) {
            int delta = it->getSizeDelta(Rewrite.getSourceMgr());
            totalOffset += delta;
            offset += delta;
        }
    }
    return totalOffset;
}

SourceRange SourceRewriter::getAdjustedRange(SourceRange Range) const {
    int offset = getOffsetToAdjustLoc(Range.getBegin());
    SourceLocation adjustedBegin = Range.getBegin().getLocWithOffset(offset);
    SourceLocation adjustedEnd = Range.getEnd().getLocWithOffset(offset);
    SourceRange adjustedRange(adjustedBegin, adjustedEnd);
    return adjustedRange;
}


std::string SourceRewriter::getRewrittenText(SourceRange Range) const {
    SourceManager &sourceManager = Rewrite.getSourceMgr();
    int rangeBegin = sourceManager.getFileOffset(Range.getBegin());
    int rangeEnd = sourceManager.getFileOffset(Range.getEnd());

    int start = rangeBegin;
    int stop = rangeEnd;

    FileID fileID = sourceManager.getFileID(Range.getBegin());

    for (auto it = Replacements.begin(); it != Replacements.end(); it++) {
        FileID replacementFileID = sourceManager.getFileID(it->replaceRange.getBegin());
        if (it->intersectsRange(Range) && fileID == replacementFileID) {
            int begin = sourceManager.getFileOffset(it->replaceRange.getBegin());
            int end = sourceManager.getFileOffset(it->replaceRange.getEnd());
            int newEnd = it->insertedText.size() + begin;
            int maxEnd = std::max(end, newEnd);

            // An edit that has occurred before the range
            if (begin <= start && start <= maxEnd) {
                int delta = (maxEnd - std::min(end, newEnd));
                start += delta;
            } else { // An edit that is inside the range
                stop += (newEnd - stop);
            }
        }
    }

    return Rewrite.getRewrittenText(Range, start - rangeBegin, stop - rangeEnd);
}

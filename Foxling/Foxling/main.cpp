#include <string.h>
#include <string>

#include "clang/Frontend/FrontendActions.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/AST/ASTContext.h"
#include "clang/ASTMatchers/ASTMatchers.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "clang/Rewrite/Frontend/ASTConsumers.h"
#include "clang/Tooling/CommonOptionsParser.h"
#include "clang/Tooling/Tooling.h"
#include "llvm/Support/CommandLine.h"

#include "Rewriter.h"
#include "source_rewriter.h"
#include "compound_stmt_rewriter.h"
#include "unary_rewriter.h"
#include "objc_message_rewriter.h"
#include "objc_property_rewriter.h"
#include "objc_matchers.h"
#include "prefix_rewriter.h"

using namespace clang;
using namespace clang::ast_matchers;
using namespace clang::tooling;
using namespace llvm;

static llvm::cl::OptionCategory FoxlingTool("foxling options");
static cl::extrahelp CommonHelp(CommonOptionsParser::HelpMessage);

static Foxling::Rewriter rewriter;

namespace Foxling {

    /// "Main" entrypoint for all refactoring operations
    /// All the rewriters are wired together here.
    class ASTConsumer : public ASTConsumer {
    public:
        ASTConsumer(Rewriter &r) : Rewrite(r) {}

        void HandleTranslationUnit(ASTContext &Context);
    private:
        Rewriter &Rewrite;
    };

    void ASTConsumer::HandleTranslationUnit(ASTContext &Context) {
        MatchFinder Finder;

        std::string injectCode = "fthread_yield();";

        SourceRewriter SourceRewrite(Rewrite);

        // Note about rewriters listed here:
        //   Completely replacing the original AST text will most likely
        //   cause corruption of the source for the final output since the
        //   SourceRewriter can not correctly keep track of changes.

        CompoundStmtRewriter RewriteCompoundStmt(SourceRewrite, injectCode);
        Finder.addMatcher(compoundStmt().bind("stmts"), &RewriteCompoundStmt);

        ObjCMessageRewriter RewriteObjCMessage(SourceRewrite, injectCode);
        Finder.addMatcher(objCMessageExpr().bind("msgExpr"), &RewriteObjCMessage);

        ObjCPropertyRewriter RewriteObjCProperty(SourceRewrite, injectCode);
        Finder.addMatcher(objCPropertyRefExpr().bind("expr"), &RewriteObjCProperty);

        UnaryRewriter RewriteUnary(SourceRewrite, injectCode, Context);
        Finder.addMatcher(unaryOperator().bind("op"), &RewriteUnary);

        Finder.matchAST(Context);

        // we need a newline here because compiler directives must be on new lines.
        prefixTranslationUnit(Context, Rewrite, "void fthread_yield(void);\n");
    }

    class FrontendAction : public ASTFrontendAction {
    public:
        virtual std::unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &CI,
                                                               StringRef InFile) {
            rewriter.setSourceMgr(CI.getSourceManager(), CI.getLangOpts());
            return std::unique_ptr<ASTConsumer>(new ASTConsumer(rewriter));
        }
    };
    
}

int main(int argc, const char * argv[]) {
    CommonOptionsParser op(argc, argv, llvm::cl::GeneralCategory, NULL);
    ClangTool Tool(op.getCompilations(), op.getSourcePathList());
    
    int result = Tool.run(newFrontendActionFactory<Foxling::FrontendAction>().get());
    if (result) {
        return result;
    }

    // print final output
    rewriter.getEditBuffer(rewriter.getSourceMgr().getMainFileID()).write(outs());
    return result;
}

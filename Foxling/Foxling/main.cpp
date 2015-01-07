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

    class PrefixDeclRewriter : public MatchFinder::MatchCallback {
    public:
        PrefixDeclRewriter(SourceRewriter &r, std::string prefix, std::string key)
        : Rewrite(r), Prefix(prefix), BindKey(key) {}

        void run(const MatchFinder::MatchResult &Result) {
            if (const Decl *decl = Result.Nodes.getNodeAs<Decl>(BindKey)) {
                if (decl->getSourceRange().isValid()) {
                    Rewrite.InsertText(decl->getLocStart(), Prefix);
                }
            }
        }
    private:
        SourceRewriter &Rewrite;
        std::string Prefix;
        std::string BindKey;
    };

    /// "Main" entrypoint for all refactoring operations
    /// All the rewriters are wired together here.
    class FoxlingASTConsumer : public ASTConsumer {
    public:
        FoxlingASTConsumer(Rewriter &r) : Rewrite(r) {}

        void HandleTranslationUnit(ASTContext &Context);
    private:
        Rewriter &Rewrite;
    };

    void FoxlingASTConsumer::HandleTranslationUnit(ASTContext &Context) {
        MatchFinder Finder;

        std::string injectCode = "fthread_yield();";
        std::string bindKey = "element";

        SourceRewriter SourceRewrite(Rewrite);

        // Note about rewriters listed here:
        //   Completely replacing the original AST text for a node will most
        //   likely cause corruption of the final source output since the
        //   SourceRewriter can not correctly keep track of changes if an entire
        //   AST node is removed.

        CompoundStmtRewriter RewriteCompoundStmt(SourceRewrite, injectCode, bindKey);
        Finder.addMatcher(compoundStmt().bind(bindKey), &RewriteCompoundStmt);

        // not as nice as prefixing one protocol definition, but this ensures
        // we don't add a new line
//        PrefixDeclRewriter PrefixDecl(SourceRewrite, "void fthread_yield(void); ", bindKey);
//        Finder.addMatcher(functionDecl().bind(bindKey), &PrefixDecl);
//        Finder.addMatcher(recordDecl().bind(bindKey), &PrefixDecl);
//        Finder.addMatcher(objCImplDecl().bind(bindKey), &PrefixDecl);
//        Finder.addMatcher(objCCategoryImplDecl().bind(bindKey), &PrefixDecl);

        ObjCMessageRewriter RewriteObjCMessage(SourceRewrite, injectCode, bindKey);
        Finder.addMatcher(objCMessageExpr().bind(bindKey), &RewriteObjCMessage);

        ObjCPropertyRewriter RewriteObjCProperty(SourceRewrite, injectCode, bindKey);
        Finder.addMatcher(objCPropertyRefExpr().bind(bindKey), &RewriteObjCProperty);

        UnaryRewriter RewriteUnary(SourceRewrite, Context, injectCode, bindKey);
        Finder.addMatcher(unaryOperator().bind(bindKey), &RewriteUnary);

        Finder.matchAST(Context);

        // we need a newline here because compiler directives must be on new lines.
        prefixTranslationUnit(Context, Rewrite, "void fthread_yield(void);\n");
    }

    class FrontendAction : public ASTFrontendAction {
    public:
        virtual std::unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &CI,
                                                               StringRef InFile) {
            rewriter.setSourceMgr(CI.getSourceManager(), CI.getLangOpts());
            return std::unique_ptr<FoxlingASTConsumer>(new FoxlingASTConsumer(rewriter));
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

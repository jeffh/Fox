#include "clang/Frontend/FrontendPluginRegistry.h"
#include "clang/AST/AST.h"
#include "clang/AST/ASTConsumer.h"
#include "clang/Frontend/CompilerInstance.h"
#include "llvm/Support/raw_ostream.h"

using namespace clang;

namespace {

    class PrintFunctionsConsumer : public ASTConsumer {
    public:
        virtual bool HandleTopLevelDecl(DeclGroupRef DG) {
            for (DeclGroupRef::iterator i = DG.begin(), e = DG.end(); i != e; ++i) {
                const Decl *D = *i;
//                if (const NamedDecl *ND = dyn_cast<NamedDecl>(D))
//                    llvm::outs() << "top-level-decl: \"" << ND->getNameAsString() << "\"\n";
            }

            return true;
        }
    };

    class PrintFunctionNamesAction : public PluginASTAction {
    protected:
        std::unique_ptr<ASTConsumer>CreateASTConsumer(CompilerInstance &CI,
                                                       llvm::StringRef) {
            return std::unique_ptr<ASTConsumer>();
        }

        bool ParseArgs(const CompilerInstance &CI,
                       const std::vector<std::string>& args) {
            for (std::size_t i = 0, e = args.size(); i != e; ++i) {
                llvm::outs() << "PrintFunctionNames arg = " << args[i] << "\n";

                // Example error handling.
                if (args[i] == "-an-error") {
                    DiagnosticsEngine &D = CI.getDiagnostics();
                    unsigned DiagID = D.getCustomDiagID(DiagnosticsEngine::Error,
                                                        "invalid argument '%0'");
                    D.Report(DiagID) << args[i];
                    return false;
                }
            }
            if (args.size() && args[0] == "help")
                PrintHelp(llvm::outs());
            
            return true;
        }
        void PrintHelp(llvm::raw_ostream& ros) {
            ros << "Help for PrintFunctionNames plugin goes here\n";
        }
        
    };
    
}

static FrontendPluginRegistry::Add<PrintFunctionNamesAction>
X("print-fns", "print function names");
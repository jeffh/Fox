// protocols
#import "FOXStateMachine.h"
#import "FOXStateTransition.h"
#import "FOXRandom.h"
#import "FOXGenerator.h"

// data structures
#import "FOXSequence.h"
#import "FOXRoseTree.h"
#import "FOXRunnerResult.h"
#import "FOXCommand.h"
#import "FOXExecutedCommand.h"
#import "FOXTransition.h"
#import "FOXPropertyResult.h"
#import "FOXExecutedProgram.h"
#import "FOXProgram.h"

// generators
#import "FOXCoreGenerators.h"
#import "FOXNumericGenerators.h"
#import "FOXStringGenerators.h"
#import "FOXSetGenerators.h"
#import "FOXArrayGenerators.h"
#import "FOXDictionaryGenerators.h"
#import "FOXPropertyGenerators.h"
#import "FOXStateMachineGenerators.h"
#import "FOXGenericGenerators.h"

// stateful testing tools
#import "FOXFiniteStateMachine.h"
#import "FOXParallelGenerators.h"
#import "FOXScheduler.h"

// randomizers
#import "FOXConstantRandom.h"
#import "FOXDeterministicRandom.h"

// runner
#import "FOXRunner.h"
#import "FOXEnvironment.h"
#import "FOXDebugging.h"

// reporters
#import "FOXStandardReporter.h"
#import "FOXDebugReporter.h"

// DSL
#import "FOXMacros.h"
#import "FOXDSL.h"

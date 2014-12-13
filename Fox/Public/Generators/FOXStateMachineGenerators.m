#import "FOXStateMachineGenerators.h"
#import "FOXGenerator.h"
#import "FOXCoreGenerators.h"
#import "FOXStateMachine.h"
#import "FOXArrayGenerators.h"
#import "FOXStateTransition.h"
#import "FOXRoseTree.h"
#import "FOXCommand.h"
#import "FOXExecutedCommand.h"
#import "FOXStateMachineGenerator.h"
#import "FOXSequence.h"
#import "FOXMath.h"
#import "FOXDictionary.h"
#import "FOXPrettyArray.h"
#import "FOXNumericGenerators.h"
#import "FOXRandom.h"
#import "FOXFiber.h"


FOX_EXPORT id<FOXGenerator> FOXNextGenCommand(id<FOXStateMachine> stateMachine, id modelState) {
    NSArray *allTransitions = [stateMachine allTransitions];
    NSMutableArray *filteredTransitions = [NSMutableArray arrayWithCapacity:allTransitions.count];

    for (id<FOXStateTransition> transition in allTransitions) {
        if ([transition satisfiesPreConditionForModelState:modelState]) {
            [filteredTransitions addObject:transition];
        }
    }

    id<FOXGenerator> transitionsGenerator = FOXElements(filteredTransitions);
    return FOXGenBind(transitionsGenerator, ^id<FOXGenerator>(FOXRoseTree *generatorTree) {
        id<FOXStateTransition> transition = generatorTree.value;
        id<FOXGenerator> argGenerator = nil;

        if ([transition respondsToSelector:@selector(generator)]) {
            argGenerator = [transition generator];
        } else {
            argGenerator = FOXReturn(@[]);
        }

        return FOXMap(FOXTuple(@[FOXReturn(transition), argGenerator]), ^id(NSArray *commandTuple) {
            return [[FOXCommand alloc] initWithTransition:commandTuple[0] generatedValue:commandTuple[1]];
        });
    });
}


FOX_EXPORT id<FOXGenerator> FOXGenCommand(id<FOXStateMachine> stateMachine) {
    id<FOXGenerator> transitionsGenerator = FOXElements([stateMachine allTransitions]);
    return FOXGenBind(transitionsGenerator, ^id<FOXGenerator>(FOXRoseTree *generatorTree) {
        id<FOXStateTransition> transition = generatorTree.value;
        id<FOXGenerator> argGenerator = nil;

        if ([transition respondsToSelector:@selector(generator)]) {
            argGenerator = [transition generator];
        } else {
            argGenerator = FOXReturn(@[]);
        }

        return FOXMap(FOXTuple(@[FOXReturn(transition), argGenerator]), ^id(NSArray *commandTuple) {
            return [[FOXCommand alloc] initWithTransition:commandTuple[0] generatedValue:commandTuple[1]];
        });
    });
}


FOX_EXPORT id<FOXGenerator> FOXCommands(id<FOXStateMachine> stateMachine) {
    return [[FOXStateMachineGenerator alloc] initWithStateMachine:stateMachine];
}

FOX_EXPORT id<FOXGenerator> FOXExecuteCommands(id<FOXStateMachine> stateMachine, id (^subject)(void)) {
    return FOXMap(FOXCommands(stateMachine), ^id(NSArray *commands) {
        return [stateMachine executeCommandSequence:commands subject:subject()];
    });
}

FOX_EXPORT BOOL FOXExecutedSuccessfully(NSArray *executedCommands) {
    for (FOXExecutedCommand *cmd in executedCommands) {
        if (![cmd wasSuccessfullyExecuted]) {
            return NO;
        }
    }

    return YES;
}

FOX_EXPORT id<FOXGenerator> FOXParallelCommands(id<FOXStateMachine> stateMachine) {
    id<FOXGenerator> prefixGen = FOXCommands(stateMachine);
    return FOXBind(prefixGen, ^id<FOXGenerator>(NSArray *prefixCommands) {
        // "Private" parameters for parallel test generation.
        //
        // WARNING: these parameters tweak the problem space of linearizability
        //          checking which is NP-Complete (roughly O(N!) where N=total
        //          number of commands). Also, Fox's currently checker is
        //          the most naive solver - brute-force.
        //
        //          These variables are not exposed as tweakable parameters
        //          for those reasons.
        //
        //          Current worse case: (2*3)! = 720 possible linearizations.
        //          So each failing parallel test will spawn 720 more
        //          serialized tests to run. Remember that every shrink attempt
        //          counts as a failing test too.
        NSNumber *minCommandsPerThread = @2;
        NSNumber *maxCommandsPerThread = @2;
        const NSUInteger minNumOfThreads = 2;
        const NSUInteger maxNumOfThreads = 3;

        id prefixState = [stateMachine modelStateFromCommandSequence:prefixCommands];
        id<FOXGenerator> process = [[FOXStateMachineGenerator alloc] initWithStateMachine:stateMachine
                                                                        initialModelState:prefixState
                                                                                  minSize:minCommandsPerThread
                                                                                  maxSize:maxCommandsPerThread];
        id<FOXGenerator> processesGenerator = FOXArrayOfSizeRange(process, minNumOfThreads, maxNumOfThreads);
        return FOXBind(processesGenerator, ^id<FOXGenerator>(NSArray *processCommands) {
            FOXDictionary *dictionary = [FOXDictionary dictionaryWithDictionary:@{@"command prefix": prefixCommands,
                                                                                  @"processes": processCommands}];
            return FOXReturn(dictionary);
        });
    });
}

// AKA - the linearizability checker
FOX_EXPORT BOOL FOXExecutedSuccessfullyInParallel(NSDictionary *parallelCommands, id<FOXStateMachine> stateMachine, id(^subjectFactory)()) {
    NSArray *executedPrefix = parallelCommands[@"command prefix"];
    if (!FOXExecutedSuccessfully(executedPrefix)) {
        return NO;
    }
    NSArray *executedProcesses = parallelCommands[@"processes"];
    NSMutableArray *commands = [NSMutableArray array];
    for (NSArray *clientCmds in executedProcesses) {
        [commands addObjectsFromArray:clientCmds];
    }
    if ([commands count] == 0) {
        return YES;
    }

    NSArray *prefix = [executedPrefix valueForKey:@"command"];

    // There can be lots of permutations which can aggressively expand
    // our memory heap. Keeping memory allocations can quickly become
    // the bottleneck.
    __block BOOL executedSuccessfully = NO;
    eachPermutation(commands, ^BOOL(NSArray *permutation) {
        @autoreleasepool {
            if (executedSuccessfully) {
                return NO;
            }
            NSArray *cmds = [permutation valueForKey:@"command"];
            id subject = subjectFactory();
            [stateMachine executeCommandSequence:prefix subject:subject];
            NSArray *ecmds = [stateMachine executeCommandSequence:cmds subject:subject];
            executedSuccessfully = [ecmds isEqual:permutation];
            return !executedSuccessfully;
        }
    });
    return executedSuccessfully;
}

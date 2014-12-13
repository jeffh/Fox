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
#import "FOXLogicalProcess.h"
#import "FOXSequence.h"
#import "FOXMath.h"
#import "FOXDictionary.h"
#import "FOXPrettyArray.h"


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
        NSNumber *minCommandsPerThread = @1;
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

FOX_EXPORT id<FOXGenerator> FOXRunParallelCommands(id<FOXStateMachine> stateMachine, id (^subjectFactory)(void)) {
    return FOXMap(FOXParallelCommands(stateMachine), ^id(NSDictionary *parallelCommands) {
        @autoreleasepool {
            NSArray *prefixCommands = parallelCommands[@"command prefix"];
            NSArray *processCommands = parallelCommands[@"processes"];
            id subject = subjectFactory();
            id prefixModelState = [stateMachine modelStateFromCommandSequence:prefixCommands];
            NSArray *executedPrefix = [stateMachine executeCommandSequence:prefixCommands subject:subject];
            NSMutableArray *processes = [NSMutableArray array];
            NSMutableArray *threads = [NSMutableArray array];
            dispatch_group_t group = dispatch_group_create();
            dispatch_group_t startGroup = dispatch_group_create();
            dispatch_group_enter(startGroup);
            for (NSArray *commands in processCommands) {
                dispatch_group_enter(group);
                FOXLogicalProcess *process = [[FOXLogicalProcess alloc] initWithStartingModelState:prefixModelState
                                                                                      stateMachine:stateMachine
                                                                                          commands:commands
                                                                                           subject:subject
                                                                                             group:group
                                                                                        startGroup:startGroup];
                [processes addObject:process];
                [threads addObject:[[NSThread alloc] initWithTarget:process
                                                           selector:@selector(run)
                                                             object:nil]];
            }
            [threads makeObjectsPerformSelector:@selector(start)];
            dispatch_group_leave(startGroup);
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            NSArray *executedCommands = [processes valueForKey:NSStringFromSelector(@selector(result))];
            executedCommands = [FOXPrettyArray arrayWithArray:executedCommands];
            return [FOXDictionary dictionaryWithDictionary:@{@"command prefix": executedPrefix,
                                                             @"processes": executedCommands}];
        }
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

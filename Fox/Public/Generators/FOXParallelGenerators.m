#import "FOXParallelGenerators.h"
#import "FOXGenerator.h"
#import "FOXRandom.h"
#import "FOXCoreGenerators.h"
#import "FOXNumericGenerators.h"
#import "FOXStateMachine.h"
#import "FOXStateMachineGenerators.h"
#import "FOXDictionary.h"
#import "FOXPrettyArray.h"
#import "FOXScheduler.h"
#import "FOXStateMachineGenerator.h"
#import "FOXArrayGenerators.h"
#import "FOXBlock.h"
#import "FOXMath.h"
#import "FOXExecutedProgram.h"
#import "FOXExecutedCommand.h"
#import "FOXProgram.h"

static BOOL FOXExecutedSuccessfullyInParallel(FOXExecutedProgram *parallelExecution, id(^subjectFactory)());

FOX_EXPORT id<FOXGenerator> FOXParallelCommands(id<FOXStateMachine> stateMachine) {
    id<FOXGenerator> prefixGen = [[FOXStateMachineGenerator alloc] initWithStateMachine:stateMachine];
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

        id prefixState = [stateMachine modelStateFromCommandSequence:prefixCommands
                                                  startingModelState:[stateMachine initialModelState]];
        id<FOXGenerator> process = [[FOXStateMachineGenerator alloc] initWithStateMachine:stateMachine
                                                                        initialModelState:prefixState
                                                                                  minSize:minCommandsPerThread
                                                                                  maxSize:maxCommandsPerThread];
        id<FOXGenerator> processesGenerator = FOXArrayOfSizeRange(process, minNumOfThreads, maxNumOfThreads);
        return FOXBind(processesGenerator, ^id<FOXGenerator>(NSArray *processCommands) {
            FOXProgram *plan = [[FOXProgram alloc] init];
            plan.serialCommands    = prefixCommands;
            plan.parallelCommands  = processCommands;
            plan.stateMachine      = stateMachine;
            return FOXReturn(plan);
        });
    });
}

FOX_EXPORT FOXExecutedProgram *FOXRunParallelCommands(FOXProgram *plan,
                                                      id (^subjectFactory)()) {
    @autoreleasepool {
        id<FOXStateMachine> stateMachine = plan.stateMachine;
        NSArray *prefixCommands = plan.serialCommands;
        NSArray *processCommands = plan.parallelCommands;

        id subject = subjectFactory();
        id prefixModelState = [stateMachine modelStateFromCommandSequence:prefixCommands
                                                       startingModelState:[stateMachine initialModelState]];
        NSArray *executedPrefix = [stateMachine executeCommandSequence:prefixCommands
                                                               subject:subject
                                                    startingModelState:[stateMachine initialModelState]];
        NSMutableArray *threads = [NSMutableArray array];
        NSMutableArray *blocks = [NSMutableArray array];
        dispatch_group_t group = dispatch_group_create();
        size_t numThreads = 0;
        for (NSArray *commands in processCommands) {
            dispatch_group_enter(group);
            FOXBlock *block = [[FOXBlock alloc] initWithGroup:group block:^id{
                return [stateMachine executeCommandSequence:commands
                                                    subject:subject
                                         startingModelState:prefixModelState];
            }];
            [blocks addObject:block];

            NSThread *thread = [[NSThread alloc] initWithTarget:block
                                                       selector:@selector(run)
                                                         object:nil];
            thread.name = [NSString stringWithFormat:@"Fox Test Thread %lu", numThreads + 1];
            [threads addObject:thread];
            numThreads++;
        }
        [threads makeObjectsPerformSelector:@selector(start)];
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        threads = nil;

        NSMutableArray *results = [blocks valueForKey:NSStringFromSelector(@selector(result))];
        NSArray *executedCommands = [FOXPrettyArray arrayWithArray:results];

        FOXExecutedProgram *result = [[FOXExecutedProgram alloc] init];
        result.program = plan;
        result.serialCommands      = executedPrefix;
        result.parallelCommands    = executedCommands;
        result.succeeded           = FOXExecutedSuccessfullyInParallel(result, subjectFactory);
        return result;
    }
}

// AKA - the linearizability checker
static BOOL FOXExecutedSuccessfullyInParallel(FOXExecutedProgram *result, id(^subjectFactory)()) {
    id<FOXStateMachine> stateMachine = result.program.stateMachine;
    NSArray *executedPrefix = result.serialCommands;
    if (!FOXExecutedSuccessfully(executedPrefix)) {
        return NO;
    }
    NSArray *executedProcesses = result.parallelCommands;
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
            id subject = subjectFactory();
            [stateMachine executeCommandSequence:prefix
                                         subject:subject
                              startingModelState:[stateMachine initialModelState]];
            NSArray *linearizedExecutedCommands = [stateMachine executeCommandSequence:[permutation valueForKey:@"command"]
                                                                               subject:subject
                                                                    startingModelState:[stateMachine initialModelState]];
            executedSuccessfully = [linearizedExecutedCommands isEqual:permutation];
            return !executedSuccessfully;
        }
    });
    return executedSuccessfully;
}

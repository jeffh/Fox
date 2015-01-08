#import "FOXParallelGenerators.h"
#import "FOXGenerator.h"
#import "FOXRandom.h"
#import "FOXCoreGenerators.h"
#import "FOXNumericGenerators.h"
#import "FOXStateMachine.h"
#import "FOXStateMachineGenerators.h"
#import "FOXDictionary.h"
#import "FOXPrettyArray.h"
#import "FOXThread.h"
#import "FOXStateMachineGenerator.h"
#import "FOXArrayGenerators.h"
#import "FOXBlock.h"
#import "FOXMath.h"


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

FOX_EXPORT id<FOXGenerator> FOXExecuteParallelCommands(id<FOXStateMachine> stateMachine, id (^subjectFactory)(void)) {
    return FOXBind(FOXSeed(), ^id<FOXGenerator>(id<FOXRandom> prng) {
        return FOXMap(FOXParallelCommands(stateMachine), ^id(NSDictionary *parallelCommands) {
            @autoreleasepool {
                fthread_override(true);
                fthread_init();
                NSArray *prefixCommands = parallelCommands[@"command prefix"];
                NSArray *processCommands = parallelCommands[@"processes"];
                id subject = subjectFactory();
                id prefixModelState = [stateMachine modelStateFromCommandSequence:prefixCommands];
                NSArray *executedPrefix = [stateMachine executeCommandSequence:prefixCommands subject:subject];
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
                fthread_run_and_wait(fthread_random, (__bridge void *)(prng));
                fthread_override(false);

                [threads makeObjectsPerformSelector:@selector(cancel)];
                threads = nil;

                NSMutableArray *results = [blocks valueForKey:NSStringFromSelector(@selector(result))];
                NSArray *executedCommands = [FOXPrettyArray arrayWithArray:results];
                return [FOXDictionary dictionaryWithDictionary:@{@"command prefix": executedPrefix,
                                                                 @"processes": executedCommands}];
            }
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

#import "FOXParallelGenerators.h"
#import "FOXGenerator.h"
#import "FOXRandom.h"
#import "FOXCoreGenerators.h"
#import "FOXNumericGenerators.h"
#import "FOXStateMachine.h"
#import "FOXFiber.h"
#import "FOXStateMachineGenerators.h"
#import "FOXDictionary.h"
#import "FOXPrettyArray.h"

typedef struct {
    size_t index;
    id stateMachine;
    id commands;
    id subject;
    id prefixModelState;
    id result;
} FOXParallelFiberData;

void _FOXParallelFiberMain(void *data) {
    FOXParallelFiberData *d = data;
    id result = [d->stateMachine executeCommandSequence:d->commands
                                                subject:d->subject
                                     startingModelState:d->prefixModelState];
    d->result = [result retain];
}

FOX_EXPORT id<FOXGenerator> FOXExecuteParallelCommands(id<FOXStateMachine> stateMachine, id (^subjectFactory)(void)) {
    return FOXBind(FOXSeed(), ^id<FOXGenerator>(id<FOXRandom> prng) {
        return FOXMap(FOXParallelCommands(stateMachine), ^id(NSDictionary *parallelCommands) {
            NSArray *prefixCommands = parallelCommands[@"command prefix"];
            NSArray *processCommands = parallelCommands[@"processes"];
            id subject = subjectFactory();
            id prefixModelState = [stateMachine modelStateFromCommandSequence:prefixCommands];
            NSArray *executedPrefix = [stateMachine executeCommandSequence:prefixCommands subject:subject];
            NSMutableArray *threads = [NSMutableArray array];
            FOXFiberSchedulerPtr scheduler = FOXFiberSchedulerCreate(FOXFiberSchedulerRandom, prng);
            FOXParallelFiberData **data = malloc(sizeof(FOXParallelFiberData *) * processCommands.count);
            size_t numThreads = 0;
            for (NSArray *commands in processCommands) {
                char name[50];
                sprintf(name, "net.jeffhui.fox.fiber.%lu", numThreads);
                data[numThreads] = calloc(sizeof(FOXParallelFiberData), processCommands.count);
                data[numThreads]->index = numThreads;
                data[numThreads]->stateMachine = stateMachine;
                data[numThreads]->commands = commands;
                data[numThreads]->subject = subject;
                data[numThreads]->prefixModelState = prefixModelState;

                FOXFiberPtr fiber = FOXFiberCreate(name, &_FOXParallelFiberMain, data[numThreads]);
                FOXFiberSchedulerAdd(scheduler, fiber);
                numThreads++;
            }
            [threads makeObjectsPerformSelector:@selector(start)];
            FOXFiberSchedulerRun(scheduler);
            FOXFiberSchedulerFree(scheduler);

            NSMutableArray *results = [NSMutableArray array];
            for (size_t i = 0; i < FOXFiberSchedulerCount(scheduler); i++) {
                id result = data[i]->result;
                [results addObject:result];
                [result release];
                free(data[i]);
            }
            free(data);
            NSArray *executedCommands = [FOXPrettyArray arrayWithArray:results];
            return [FOXDictionary dictionaryWithDictionary:@{@"command prefix": executedPrefix,
                                                             @"processes": executedCommands}];
        });
    });
}

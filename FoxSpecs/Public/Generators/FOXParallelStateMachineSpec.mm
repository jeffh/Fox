#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"
#import "QueueRemoveTransition.h"
#import "QueueAddTransition.h"
#import "Queue.h"
#import "Ticker.h"
#import <objc/runtime.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(FOXParallelStateMachineSpec)

describe(@"FOXParallelStateMachine", ^{

#ifdef FOXSPECS_INSTRUMENTED
    it(@"should fail if the ticker does not support atomic methods (instrumented yielding)", ^{
        FOXFiniteStateMachine *stateMachine = [[FOXFiniteStateMachine alloc] initWithInitialModelState:@0];

        FOXTransition *incrTransition = [FOXTransition byCallingSelector:@selector(increment)
                                                          nextModelState:^id(NSNumber *modelState, id generatedValue) {
                                                              return @(modelState.integerValue + 1);
                                                          }];
        FOXTransition *resetTransition = [FOXTransition byCallingSelector:@selector(reset)
                                                           nextModelState:^id(id modelState, id generatedValue) {
                                                               return @0;
                                                           }];
        incrTransition.frequency = 3;
        resetTransition.frequency = 1;

        [stateMachine addTransition:incrTransition];
        [stateMachine addTransition:resetTransition];

        id<FOXGenerator> commandsWithRandom = FOXTuple(@[FOXParallelProgram(stateMachine),
                                                         FOXSeed()]);

        id<FOXGenerator> property = FOXForAll(commandsWithRandom, ^BOOL(NSArray *tuple) {
            FOXProgram *program = tuple[0];
            id<FOXRandom> random = tuple[1];
            FOXScheduler *scheduler = [[FOXScheduler alloc] initWithRandom:random];
            __block FOXExecutedProgram *executedProgram = nil;
            [scheduler runAndWait:^{
                executedProgram = FOXRunParallelProgram(program, ^id{
                    return [Ticker new];
                });
            }];
            return FOXReturnOrRaisePrettyProgram(executedProgram);
        });

        FOXRunnerResult *result = [FOXSpecHelper resultForProperty:property];
        result.succeeded should be_falsy;
        FOXExecutedProgram *execution = result.smallestFailingValue;
        execution.serialCommands should be_empty;
    });

    it(@"should pass if the subject has an atomic API (instrumented yielding)", ^{
        FOXFiniteStateMachine *stateMachine = [[FOXFiniteStateMachine alloc] initWithInitialModelState:@0];

        FOXTransition *incrTransition = [FOXTransition byCallingSelector:@selector(atomicIncrement)
                                                          nextModelState:^id(NSNumber *modelState, id generatedValue) {
                                                              return @(modelState.integerValue + 1);
                                                          }];
        FOXTransition *resetTransition = [FOXTransition byCallingSelector:@selector(atomicReset)
                                                           nextModelState:^id(id modelState, id generatedValue) {
                                                               return @0;
                                                           }];
        incrTransition.frequency = 3;
        resetTransition.frequency = 1;

        [stateMachine addTransition:incrTransition];
        [stateMachine addTransition:resetTransition];

        id<FOXGenerator> parallelCommands = FOXTuple(@[FOXParallelProgram(stateMachine),
                                                       FOXSeed()]);
        id<FOXGenerator> property = FOXForAll(parallelCommands, ^BOOL(NSArray *tuple) {
            FOXProgram *program = tuple[0];
            id<FOXRandom> random = tuple[1];

            FOXScheduler *scheduler = [[FOXScheduler alloc] initWithRandom:random];
            __block FOXExecutedProgram *executedProgram = nil;
            [scheduler runAndWait:^{
                executedProgram = FOXRunParallelProgram(program, ^id{
                    return [Ticker new];
                });
            }];
            return FOXReturnOrRaisePrettyProgram(executedProgram);
        });

        FOXRunnerResult *result = [FOXSpecHelper resultForProperty:property];
        result.succeeded should be_truthy;
    });
#endif // FOXSPECS_INSTRUMENTED

    it(@"should pass if the subject has an atomic API (explicit cooperation)", ^{
        FOXFiniteStateMachine *stateMachine = [[FOXFiniteStateMachine alloc] initWithInitialModelState:@0];

        FOXTransition *incrTransition = [FOXTransition byCallingSelector:@selector(atomicIncrementWithManualInstrumentation)
                                                          nextModelState:^id(NSNumber *modelState, id generatedValue) {
                                                              return @(modelState.integerValue + 1);
                                                          }];
        FOXTransition *resetTransition = [FOXTransition byCallingSelector:@selector(atomicResetWithManualInstrumentation)
                                                           nextModelState:^id(id modelState, id generatedValue) {
                                                               return @0;
                                                           }];
        incrTransition.frequency = 3;
        resetTransition.frequency = 1;

        [stateMachine addTransition:incrTransition];
        [stateMachine addTransition:resetTransition];

        id<FOXGenerator> parallelCommands = FOXTuple(@[FOXParallelProgram(stateMachine),
                                                       FOXSeed()]);
        id<FOXGenerator> property = FOXForAll(parallelCommands, ^BOOL(NSArray *tuple) {
            FOXProgram *plan = tuple[0];
            id<FOXRandom> random = tuple[1];

            FOXScheduler *scheduler = [[FOXScheduler alloc] initWithRandom:random];
            __block FOXExecutedProgram *executedProgram = nil;
            [scheduler runAndWait:^{
                executedProgram = FOXRunParallelProgram(plan, ^id {
                    return [Ticker new];
                });
            }];
            return FOXReturnOrRaisePrettyProgram(executedProgram);
        });

        FOXRunnerResult *result = [FOXSpecHelper resultForProperty:property];
        result.succeeded should be_truthy;
    });

    it(@"should fail if the ticker does not support atomic methods (explicit cooperation)", ^{
        FOXFiniteStateMachine *stateMachine = [[FOXFiniteStateMachine alloc] initWithInitialModelState:@0];

        FOXTransition *incrTransition = [FOXTransition byCallingSelector:@selector(incrementWithManualInstrumentation)
                                                          nextModelState:^id(NSNumber *modelState, id generatedValue) {
                                                              return @(modelState.integerValue + 1);
                                                          }];
        FOXTransition *resetTransition = [FOXTransition byCallingSelector:@selector(resetWithManualInstrumentation)
                                                           nextModelState:^id(id modelState, id generatedValue) {
                                                               return @0;
                                                           }];
        incrTransition.frequency = 3;
        resetTransition.frequency = 1;

        [stateMachine addTransition:incrTransition];
        [stateMachine addTransition:resetTransition];

        id<FOXGenerator> parallelCommands = FOXTuple(@[FOXParallelProgram(stateMachine),
                                                       FOXSeed()]);
        id<FOXGenerator> property = FOXForAll(parallelCommands, ^BOOL(NSArray *tuple) {
            FOXProgram *pcommands = tuple[0];
            id<FOXRandom> random = tuple[1];

            FOXScheduler *scheduler = [[FOXScheduler alloc] initWithRandom:random];

            __block FOXExecutedProgram *executedProgram = nil;
            [scheduler runAndWait:^{
                executedProgram = FOXRunParallelProgram(pcommands, ^id {
                    return [Ticker new];
                });
            }];
            return FOXReturnOrRaisePrettyProgram(executedProgram);
        });

        FOXRunnerResult *result = [FOXSpecHelper resultForProperty:property];
        result.succeeded should be_falsy;
        FOXExecutedProgram *execution = result.smallestFailingValue;
        execution.serialCommands should be_empty;
    });
});

SPEC_END

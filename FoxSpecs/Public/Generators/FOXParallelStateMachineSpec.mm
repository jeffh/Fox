#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"
#import "QueueRemoveTransition.h"
#import "QueueAddTransition.h"
#import "Queue.h"
#import "Ticker.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXParallelStateMachineSpec)

describe(@"FOXParallelStateMachine", ^{
    it(@"should fail if the ticker does not support atomic methods", ^{
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

        id<FOXGenerator> executedCommands = FOXRunParallelCommands(stateMachine, ^id{
            return [Ticker new];
        });
        id<FOXGenerator> property = FOXAlways(10, FOXForAll(executedCommands, ^BOOL(NSDictionary *pcommands) {
            return FOXExecutedSuccessfullyInParallel(pcommands, stateMachine,  ^id{
                return [Ticker new];
            });
        }));

        FOXRunnerResult *result = [FOXSpecHelper resultForProperty:property];
        result.succeeded should be_falsy;
        // shrinking not reliable due to OS-level concurrency
    });

    it(@"should shrink if the ticker does not support atomic tests, but uses the Fox scheduler", ^{
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

        id<FOXGenerator> executedCommands = FOXRunParallelCommands(stateMachine, ^id{
            return [Ticker new];
        });
        id<FOXGenerator> property = FOXAlways(10, FOXForAll(executedCommands, ^BOOL(NSDictionary *pcommands) {
            return FOXExecutedSuccessfullyInParallel(pcommands, stateMachine,  ^id{
                return [Ticker new];
            });
        }));

        FOXRunnerResult *result = [FOXSpecHelper resultForProperty:property];
        result.succeeded should be_truthy;
    });

    xit(@"should fail if the ticker does not support atomic methods", ^{
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

        id<FOXGenerator> executedCommands = FOXRunParallelCommands(stateMachine, ^id{
            return [Ticker new];
        });
        id<FOXGenerator> property = FOXAlways(10, FOXForAll(executedCommands, ^BOOL(NSDictionary *pcommands) {
            return FOXExecutedSuccessfullyInParallel(pcommands, stateMachine,  ^id{
                return [Ticker new];
            });
        }));

        FOXRunnerResult *result = [FOXSpecHelper resultForProperty:property];
        result.succeeded should be_falsy;
        // shrinking not reliable due to OS-level concurrency
    });
});

SPEC_END

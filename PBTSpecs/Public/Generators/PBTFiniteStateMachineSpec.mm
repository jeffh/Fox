#import <Cedar/Cedar.h>
#import "PBT.h"
#import "PBTQueueRemoveTransition.h"
#import "PBTQueueAddTransition.h"
#import "PBTSpecHelper.h"
#import "PBTQueue.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTFiniteStateMachineSpec)

describe(@"PBTFiniteStateMachine", ^{
    __block PBTFiniteStateMachine *stateMachine;

    beforeEach(^{
        stateMachine = [[PBTFiniteStateMachine alloc] initWithInitialModelState:@[]];

        [stateMachine addTransition:[PBTTransition byCallingSelector:@selector(addObject:)
                                                       withGenerator:PBTInteger()
                                                      nextModelState:^id(NSArray *modelState, id generatedValue) {
            return [modelState arrayByAddingObject:generatedValue];
        }]];
        [stateMachine addTransition:[[PBTQueueRemoveTransition alloc] init]];
    });

    it(@"should provide the initial state", ^{
        [stateMachine initialModelState] should equal(@[]);
    });

    it(@"should be able validate queue behavior", ^{
        id<PBTGenerator> executedCommands = PBTExecuteCommands(stateMachine, ^id {
            return [PBTQueue new];
        });
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:executedCommands
                                                         then:^BOOL(NSArray *commands) {
             return PBTExecutedSuccessfully(commands);
        }];
        result.succeeded should be_truthy;
    });
});

SPEC_END

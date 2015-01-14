#import <Cedar.h>
#import "Fox.h"
#import "QueueRemoveTransition.h"
#import "QueueAddTransition.h"
#import "FOXSpecHelper.h"
#import "Queue.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXFiniteStateMachineSpec)

describe(@"FOXFiniteStateMachine", ^{
    __block FOXFiniteStateMachine *stateMachine;

    beforeEach(^{
        stateMachine = [[FOXFiniteStateMachine alloc] initWithInitialModelState:@[]];

        [stateMachine addTransition:[FOXTransition byCallingSelector:@selector(addObject:)
                                                       withGenerator:FOXInteger()
                                                      nextModelState:^id(NSArray *modelState, id generatedValue) {
                                                          return [modelState arrayByAddingObject:generatedValue];
                                                      }]];
        [stateMachine addTransition:[[QueueRemoveTransition alloc] init]];
    });

    it(@"should provide the initial state", ^{
        [stateMachine initialModelState] should equal(@[]);
    });

    it(@"should be able validate queue behavior", ^{
        FOXAssert(FOXForAll(FOXSerialProgram(stateMachine), ^BOOL(FOXProgram *program) {
            Queue *subject = [[Queue alloc] init];
            return FOXRunSerialProgram(program, subject).succeeded;
        }));
    });
});

SPEC_END

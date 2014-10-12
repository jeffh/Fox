#import "PBTStateMachineGenerators.h"
#import "PBTGenerator.h"
#import "PBTCoreGenerators.h"
#import "PBTStateMachine.h"
#import "PBTArrayGenerators.h"
#import "PBTStateTransition.h"
#import "PBTRoseTree.h"
#import "PBTCommand.h"
#import "PBTExecutedCommand.h"


PBT_EXPORT id<PBTGenerator> PBTGenCommands(id<PBTStateMachine> stateMachine) {
    return PBTGenBind(PBTElements([stateMachine allTransitions]), ^id<PBTGenerator>(PBTRoseTree *generatorTree) {
        id<PBTStateTransition> transition = generatorTree.value;
        id<PBTGenerator> argGenerator = nil;

        if ([transition respondsToSelector:@selector(generator)]) {
            argGenerator = [transition generator];
        } else {
            argGenerator = PBTReturn(@[]);
        }

        return PBTMap(PBTTuple(@[PBTReturn(transition), argGenerator]), ^id(NSArray *commandTuple) {
            return [[PBTCommand alloc] initWithTransition:commandTuple[0] generatedValue:commandTuple[1]];
        });
    });
}


PBT_EXPORT id<PBTGenerator> PBTCommands(id<PBTStateMachine> stateMachine) {
    return PBTSuchThat(PBTArray(PBTGenCommands(stateMachine)), ^BOOL(NSArray *commands) {
        return [stateMachine isValidCommandSequence:commands];
    });
}

PBT_EXPORT id<PBTGenerator> PBTExecuteCommands(id<PBTStateMachine> stateMachine, id (^subject)(void)) {
    return PBTMap(PBTCommands(stateMachine), ^id(NSArray *commands) {
        return [stateMachine executeCommandSequence:commands initialActualState:subject()];
    });
}

PBT_EXPORT BOOL PBTExecutedSuccessfully(NSArray *executedCommands) {
    for (PBTExecutedCommand *cmd in executedCommands) {
        if (![cmd wasSuccessfullyExecuted]) {
            return NO;
        }
    }

    return YES;
}

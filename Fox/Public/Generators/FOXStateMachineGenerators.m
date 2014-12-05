#import "FOXStateMachineGenerators.h"
#import "FOXGenerator.h"
#import "FOXCoreGenerators.h"
#import "FOXStateMachine.h"
#import "FOXArrayGenerators.h"
#import "FOXStateTransition.h"
#import "FOXRoseTree.h"
#import "FOXCommand.h"
#import "FOXExecutedCommand.h"


/**
 Returns a generator of commands to execute from a given state machine.
 */
FOX_EXPORT id<FOXGenerator> FOXGenCommands(id<FOXStateMachine> stateMachine) {
    return FOXGenBind(FOXElements([stateMachine allTransitions]), ^id<FOXGenerator>(FOXRoseTree *generatorTree) {
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
    return FOXSuchThat(FOXArray(FOXGenCommands(stateMachine)), ^BOOL(NSArray *commands) {
        return [stateMachine isValidCommandSequence:commands];
    });
}

/**
 Returns a generator of executed commands using a given state machine and subject factory.
 */
FOX_EXPORT id<FOXGenerator> FOXExecuteCommands(id<FOXStateMachine> stateMachine, id (^subject)(void)) {
    return FOXMap(FOXCommands(stateMachine), ^id(NSArray *commands) {
        return [stateMachine executeCommandSequence:commands subject:subject()];
    });
}

/**
 Verifies if a given array of executed commands completed successfully.
 */
FOX_EXPORT BOOL FOXExecutedSuccessfully(NSArray *executedCommands) {
    for (FOXExecutedCommand *cmd in executedCommands) {
        if (![cmd wasSuccessfullyExecuted]) {
            return NO;
        }
    }

    return YES;
}

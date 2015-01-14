#import "FOXStateMachineGenerators.h"
#import "FOXGenerator.h"
#import "FOXCoreGenerators.h"
#import "FOXStateMachine.h"
#import "FOXExecutedCommand.h"
#import "FOXStateMachineGenerator.h"
#import "FOXExecutedProgram.h"
#import "FOXProgram.h"
#import "FOXPropertyGenerators.h"
#import "FOXRaiseResult.h"


FOX_EXPORT id<FOXGenerator> FOXSerialProgram(id<FOXStateMachine> stateMachine) {
    id<FOXGenerator> stateMachineGenerator = [[FOXStateMachineGenerator alloc] initWithStateMachine:stateMachine];
    return FOXMap(stateMachineGenerator, ^id(NSArray *commands) {
        FOXProgram *program = [[FOXProgram alloc] init];
        program.stateMachine = stateMachine;
        program.serialCommands = commands;
        return program;
    });
}

FOX_EXPORT id<FOXGenerator> FOXCommands(id<FOXStateMachine> stateMachine) {
    return FOXMap(FOXSerialProgram(stateMachine), ^id(FOXProgram *program) {
        return program.serialCommands;
    });
}

FOX_EXPORT id<FOXGenerator> FOXExecuteCommands(id<FOXStateMachine> stateMachine, id (^subject)(void)) {
    return FOXMap(FOXCommands(stateMachine), ^id(NSArray *commands) {
        return [stateMachine executeCommandSequence:commands
                                            subject:subject()
                                 startingModelState:[stateMachine initialModelState]];
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

FOX_EXPORT FOXExecutedProgram *FOXRunSerialProgram(FOXProgram *program, id subject) {
    id<FOXStateMachine> stateMachine = program.stateMachine;
    NSArray *commands = program.serialCommands;

    FOXExecutedProgram *result = [[FOXExecutedProgram alloc] init];
    result.program             = program;
    result.serialCommands      = [stateMachine executeCommandSequence:commands
                                                              subject:subject
                                                   startingModelState:[stateMachine initialModelState]];
    result.succeeded           = FOXExecutedSuccessfully(result.serialCommands);
    return result;
}

FOX_EXPORT BOOL FOXReturnOrRaisePrettyProgram(FOXExecutedProgram *program) {
    NSCAssert(program, @"Received argument was nil");
    FOXPropertyResult *result = [[FOXPropertyResult alloc] init];
    result.generatedValue = program;
    result.status = FOXRequire(program.succeeded);
    if ([result hasFailedOrRaisedException]) {
        FOXRaiseResult(result);
    }
    return YES;
}

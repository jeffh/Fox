#import "FOXStateMachineGenerators.h"
#import "FOXGenerator.h"
#import "FOXCoreGenerators.h"
#import "FOXStateMachine.h"
#import "FOXArrayGenerators.h"
#import "FOXStateTransition.h"
#import "FOXRoseTree.h"
#import "FOXCommand.h"
#import "FOXExecutedCommand.h"
#import "FOXStateMachineGenerator.h"
#import "FOXSequence.h"
#import "FOXMath.h"
#import "FOXDictionary.h"
#import "FOXPrettyArray.h"
#import "FOXNumericGenerators.h"
#import "FOXRandom.h"


FOX_EXPORT id<FOXGenerator> FOXNextGenCommand(id<FOXStateMachine> stateMachine, id modelState) {
    NSArray *allTransitions = [stateMachine allTransitions];
    NSMutableArray *filteredTransitions = [NSMutableArray arrayWithCapacity:allTransitions.count];

    for (id<FOXStateTransition> transition in allTransitions) {
        if ([transition satisfiesPreConditionForModelState:modelState]) {
            [filteredTransitions addObject:transition];
        }
    }

    id<FOXGenerator> transitionsGenerator = FOXElements(filteredTransitions);
    return FOXGenBind(transitionsGenerator, ^id<FOXGenerator>(FOXRoseTree *generatorTree) {
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


FOX_EXPORT id<FOXGenerator> FOXGenCommand(id<FOXStateMachine> stateMachine) {
    id<FOXGenerator> transitionsGenerator = FOXElements([stateMachine allTransitions]);
    return FOXGenBind(transitionsGenerator, ^id<FOXGenerator>(FOXRoseTree *generatorTree) {
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
    return [[FOXStateMachineGenerator alloc] initWithStateMachine:stateMachine];
}

FOX_EXPORT id<FOXGenerator> FOXExecuteCommands(id<FOXStateMachine> stateMachine, id (^subject)(void)) {
    return FOXMap(FOXCommands(stateMachine), ^id(NSArray *commands) {
        return [stateMachine executeCommandSequence:commands subject:subject()];
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

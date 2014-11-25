#import "FOXMacros.h"


@protocol FOXGenerator;
@protocol FOXStateMachine;


FOX_EXPORT id<FOXGenerator> FOXCommands(id<FOXStateMachine> stateMachine);
FOX_EXPORT id<FOXGenerator> FOXExecuteCommands(id<FOXStateMachine> stateMachine, id (^subject)(void));
FOX_EXPORT BOOL FOXExecutedSuccessfully(NSArray *executedCommands);

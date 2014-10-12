#import "PBTMacros.h"


@protocol PBTGenerator;
@protocol PBTStateMachine;


PBT_EXPORT id<PBTGenerator> PBTCommands(id<PBTStateMachine> stateMachine);
PBT_EXPORT id<PBTGenerator> PBTExecuteCommands(id<PBTStateMachine> stateMachine, id (^subject)(void));
PBT_EXPORT BOOL PBTExecutedSuccessfully(NSArray *executedCommands);

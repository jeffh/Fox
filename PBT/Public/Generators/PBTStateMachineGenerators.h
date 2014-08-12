#import "PBTMacros.h"


@protocol PBTGenerator;
@protocol PBTStateMachine;


PBT_EXPORT id<PBTGenerator> PBTCommands(id<PBTStateMachine> stateMachine);

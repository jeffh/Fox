#import "FOXMacros.h"

@protocol FOXGenerator;
@protocol FOXStateMachine;

FOX_EXPORT id<FOXGenerator> FOXExecuteParallelCommands(id<FOXStateMachine> stateMachine, id (^subjectFactory)(void));

#import "FOXMacros.h"

@protocol FOXGenerator;
@protocol FOXStateMachine;

FOX_EXPORT id<FOXGenerator> FOXExecuteParallelCommands(id<FOXStateMachine> stateMachine, id (^subjectFactory)(void));

FOX_EXPORT id<FOXGenerator> FOXParallelCommands(id<FOXStateMachine> stateMachine);

FOX_EXPORT BOOL FOXExecutedSuccessfullyInParallel(NSDictionary *parallelCommands, id<FOXStateMachine> stateMachine, id(^subjectFactory)());

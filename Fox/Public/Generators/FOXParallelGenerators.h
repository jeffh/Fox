#import "FOXMacros.h"

@class FOXProgram;
@class FOXExecutedProgram;
@protocol FOXGenerator;
@protocol FOXStateMachine;

FOX_EXPORT id<FOXGenerator> FOXParallelCommands(id<FOXStateMachine> stateMachine);

FOX_EXPORT FOXExecutedProgram *FOXRunParallelCommands(FOXProgram *plan,
                                                      id (^subjectFactory)());

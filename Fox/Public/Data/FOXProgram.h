#import <Foundation/Foundation.h>

@protocol FOXRandom;
@protocol FOXStateMachine;

/*! A data structure that represents a potential program to execute.
 *  The program should always execute serialCommands before parallelCommands.
 *
 *  FOXExecutedProgram is the execution of a given FOXProgram.
 */
@interface FOXProgram : NSObject

/// An array of FOXCommands to execute.
@property (nonatomic) NSArray *serialCommands;

/// An 2D-array of FOXCommands that represents each thread
/// of commands to execute.
@property (nonatomic) NSArray *parallelCommands;

/// The state machine used to generate commands.
@property (nonatomic) id<FOXStateMachine> stateMachine;

@end

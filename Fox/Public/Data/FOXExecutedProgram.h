#import <Foundation/Foundation.h>

@class FOXProgram;

/*! A data structure that represents the result of executing a given
 *  program.
 *
 *  FOXProgram is the definition of a program. FOXExecutedProgram is
 *  the results of executing it.
 */
@interface FOXExecutedProgram : NSObject

/// The program that was executed.
@property (nonatomic) FOXProgram *program;

/// An array of FOXExecutedCommands containing the result of
/// executing serialCommands specified in the program property.
///
/// May be smaller than the defined array of commands if it fails.
@property (nonatomic) NSArray *serialCommands;

/// A 2D array of FOXExecutedCommands containing the result of
/// executing parallelCommands specified in the program property.
///
/// May be smaller than the defined array of commands if it fails.
@property (nonatomic) NSArray *parallelCommands;

/// A bool indicating if the execution of the program conformed
/// to the original program's definition and state machine.
@property (nonatomic) BOOL succeeded;

@end

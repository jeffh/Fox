#import "FOXMacros.h"

@class FOXProgram;
@class FOXExecutedProgram;
@protocol FOXGenerator;
@protocol FOXStateMachine;

/*! A generator that produces FOXPrograms from the given state machine. The
 *  program executes two phases: serial and parallel commands.
 *
 *  Serial commands are always executed before running the parallel commands.
 *  Parallel commands can run in this configuration range (and can change
 *  at any time):
 *
 *   - 2-3 threads
 *   - 2-3 commands per thread
 *
 *  Programs shrink in number of commands but may not fully shrink due to the
 *  non-deterministic nature of parallel execution.
 *
 *  @param stateMachine The state machine to source commands to create.
 *  @returns a generator that produces a FOXProgram.
 */
FOX_EXPORT id<FOXGenerator> FOXParallelProgram(id<FOXStateMachine> stateMachine);

/*! Executes a given program on multiple threads for the given subject. It then
 *  checks for linearizability of the subject which is return in executed
 *  program.
 *
 *  @param program The defined program to execute
 *  @param subjectFactory A block that creates a fresh instance of the subject
 *                        under test.
 *  @returns A program that stores the results of running the program.
 */
FOX_EXPORT FOXExecutedProgram *FOXRunParallelProgram(FOXProgram *program,
                                                     id (^subjectFactory)());

// use FOXReturnOrRaisePrettyProgram() from FOXStateMachine.h

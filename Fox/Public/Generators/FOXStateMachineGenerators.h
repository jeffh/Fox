#import "FOXMacros.h"


@protocol FOXGenerator;
@protocol FOXStateMachine;
@class FOXProgram;
@class FOXExecutedProgram;

/*! A generator that produces an array of FOXCommands from the given state
 *  machine. The commands conform to the specification that the given
 *  state machine specifies.
 *
 *  The command shrinks identically to arrays - generated values are shrunk
 *  with commands that do not provoke the failure dropped from the array.
 *
 *  @param stateMachine The state machine to source commands to create.
 *  @returns a generator that produces arrays of commands to execute.
 */
FOX_EXPORT id<FOXGenerator> FOXCommands(id<FOXStateMachine> stateMachine)
FOX_DEPRECATED("Use FOXSerialCommands() instead. Will be removed in Fox 2.x.x");

/*! A generator that produce an array of FOXExecutedCommands by executing
 *  against a subject.
 *
 *  @warning Slow subject can have a significant performance impact when this
 *           generator produces values.
 *
 *  @param stateMachine The state machine to source commands to create.
 *  @param subject A block that produces a new subject as needed.
 *  @returns a generator that produces arrays of commands that have been
 *           executed against the subject.
 */
FOX_EXPORT id<FOXGenerator> FOXExecuteCommands(id<FOXStateMachine> stateMachine, id (^subject)(void))
FOX_DEPRECATED("Use FOXRunCommands() inside the FOXForAll(...) instead. Will be removed in Fox 2.x.x");

/*! A helper function that can be used to check if the given array of executed
 *  commands match the expected behavior of the state machine that was used
 *  to produce the commands.
 *
 *  @param executedCommands The array of FOXExecutedCommands to validate.
 *  @returns YES if the executed commands match the original state machine
 *           that produces them. Returns NO otherwise.
 */
FOX_EXPORT BOOL FOXExecutedSuccessfully(NSArray *executedCommands);

/*! A generator that produces FOXPrograms from the given state machine. The
 *  commands conform to the specification that the given state machine
 *  specifies.
 *
 *  The command shrinks identically to arrays - generated values are shrunk
 *  with commands that do not provoke the failure dropped from the array.
 *
 *  @param stateMachine The state machine to source commands to create.
 *  @returns a generator that produces a FOXProgram.
 */
FOX_EXPORT id<FOXGenerator> FOXSerialCommands(id<FOXStateMachine> stateMachine);

/*! A helper function that runs the list of commands against a given subject,
 *  that conforms to the specified behavior of the state machine.
 *
 *  @param program The program definition to execute.
 *  @param subject An instance of the subject to test.
 *  @returns A data structure representing the execution result which contains
 *           an array of FOXExecutedCommands in the serialCommands property and
 *           a BOOL indicating if the commands successfully executed. There
 *           are no commands executed in parallel.
 */
FOX_EXPORT FOXExecutedProgram *FOXRunSerialCommands(FOXProgram *program, id subject);

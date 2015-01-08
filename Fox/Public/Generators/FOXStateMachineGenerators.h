#import "FOXMacros.h"


@protocol FOXGenerator;
@protocol FOXStateMachine;

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
FOX_EXPORT id<FOXGenerator> FOXCommands(id<FOXStateMachine> stateMachine);

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
FOX_EXPORT id<FOXGenerator> FOXExecuteCommands(id<FOXStateMachine> stateMachine, id (^subject)(void));

/*! A helper function that can be used to check if the given array of executed
 *  commands match the expected behavior of the state machine that was used
 *  to produce the commands.
 *
 *  @param executedCommands The array of FOXExecutedCommands to validate.
 *  @returns YES if the executed commands match the original state machine
 *           that produces them. Returns NO otherwise.
 */
FOX_EXPORT BOOL FOXExecutedSuccessfully(NSArray *executedCommands);

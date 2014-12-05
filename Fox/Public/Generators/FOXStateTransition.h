#import <Foundation/Foundation.h>


@protocol FOXGenerator;


/*! Protocol to represent a state transition in a state machine.
 *  Typically each transition represents an "API call" with a set of metadata for FOX to verify
 *  the subject under test (SUT).
 *
 *  Most of the methods defined on this protocol should be stateless.
 *  They should not mutate the outside world unless explicitly mentioned.
 *
 *  The order of execution of these protocol methods are roughly the following:
 *
 *      [transition satisfiesPreconditionForModelState:modelState];
 *      id<FOXGenerator> generator = [transition generator]
 *      id value = generateRandomValueFromGenerator(generator);
 *      id nextState = [transition nextModelStateForModelState:modelState generatedValue:value];
 *      id result = [transition objectReturnedBySubject:actualState generatedValue:value];
 *      assert [transition satisfiesPostconditionInModelState:nextState
 *                                             fromModelState:modelState
 *                                                actualState:actualState
 *                                             generatedValue:value
 *                                returnedObjectFromAdvancing:result];
 *
 *  Since most of the arguments are not explicitly defined internals of FOX, you are free to use any objects
 *  as needed to represent your state machine.
 *
 *  It is also not safe to assume that any individual method will be called before any other method. So
 *  keeping track of internal state is not recommended.
 */
@protocol FOXStateTransition <NSObject>

/*! This indicates the method invocation call this transition invokes on the subject.
 *
 *  This is used for debugging information. The string should populate this template string:
 *
 *    "Called -[subject %@]"
 *
 *  Example:
 *
 *    "Called - [subject foo:1]"
 */
@required
- (NSString *)descriptionWithGeneratedValue:(id)generatedValue;

/*! This indicates if the current state can use this transition to move to
 *  a new state.
 *
 *  If not implemented, the state machine will assume that this transition IS ALWAYS possible.
 *
 *  @param modelState The current model state of the SUT. Should not be mutated.
 *  @returns A BOOL indicating if this transition can be used.
 */
@optional
- (BOOL)satisfiesPreConditionForModelState:(id)modelState;

/*! Indicates the generator that the state transition needs when advancing the
 *  next state. The generated value is then given to the remaining process of the
 *  state transition.
 *
 *  If not implemented, the state machine will generate an empty NSArray.
 *
 *  If you need multiple arguments, a tuple generator can be used here.
 *  @see FOXTupleOfGenerators
 */
@optional
- (id<FOXGenerator>)generator;

/*! Returns the next model state to advance to if the transition is followed.
 *
 *  @param previousModelState The model state of the SUT before following this transition. Should not be mutated.
 *  @param generatedValue The generated value from the generated specified in ``-[generator]``.
 *  @returns The new model state of the SUT.
 */
@required
- (id)nextModelStateFromModelState:(id)previousModelState
                    generatedValue:(id)generatedValue;

/*! Advances the state of the SUT. The implementation would mutate the SUT's state to transition its state.
 *
 *  @param subject The Subject Under Test. This gives you the opportunity to call the API under test. Assumes
 *                 mutation, since the return value of this method is intended for the postcondition.
 *  @param generatedValue The generated value from the generated specified in ``-[generator]``.
 *  @returns Any object that might be useful for the postcondition to verify. Typically this is the return value from
 *           calling a method on ``actualState``.
 */
@required
- (id)objectReturnedByInvokingSubject:(id)subject
                       generatedValue:(id)generatedValue;

/*! Verifies the state of the model with the actual state of the SUT.
 *
 *  If not implemented, the state machine will assume YES is returned.
 *
 *  @param currentModelState The current state after the transition. This is the value returned
 *                           from ``-[nextModelStateFromModelState:generatedValue:]``.
 *  @param previousModelState The state before the transition. This is the state received by
 *                            ``-[nextModelStateFromModelState:generatedValue:]``
 *  @param actualState The actual state of the SUT after the transition.
 *  @param generatedValue The value generated from ``-[generator]``
 *  @param returnedObjectFromAdvancing The object returned from ``-[objectReturnedBySubject:generatedValue:]``
 *  @returns A bool indicates if the model and actual state align. Returning NO fails the test.
 */
@optional
- (BOOL)satisfiesPostConditionInModelState:(id)currentModelState
                            fromModelState:(id)previousModelState
                                   subject:(id)subject
                            generatedValue:(id)generatedValue
                   objectReturnedBySubject:(id)returnedObject;

@end

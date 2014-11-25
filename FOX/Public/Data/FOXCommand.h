#import <Foundation/Foundation.h>


@protocol FOXStateTransition;


/*! Represents a command to execute for a state machine.
 *  A command is simply a tuple of the state transition and its generated data.
 */
@interface FOXCommand : NSObject

@property (nonatomic, readonly) id<FOXStateTransition> transition;
@property (nonatomic, readonly) id generatedValue;

- (instancetype)initWithTransition:(id<FOXStateTransition>)transition generatedValue:(id)generatedValue;

@end

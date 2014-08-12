#import <Foundation/Foundation.h>


@protocol PBTStateTransition;


/*! Represents a command to execute for a state machine.
 *  A command is simply a tuple of the state transition and its generated data.
 */
@interface PBTCommand : NSObject

@property (nonatomic, readonly) id<PBTStateTransition> transition;
@property (nonatomic, readonly) id generatedValue;

- (instancetype)initWithTransition:(id<PBTStateTransition>)transition generatedValue:(id)generatedValue;

@end

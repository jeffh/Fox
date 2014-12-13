#import <Foundation/Foundation.h>

@protocol FOXStateMachine;

@interface FOXLogicalProcess : NSObject

@property (atomic) id result;

- (instancetype)initWithStartingModelState:(id)modelState
                              stateMachine:(id<FOXStateMachine>)stateMachine
                                  commands:(NSArray *)commands
                                   subject:(id)subject
                                     group:(dispatch_group_t)group
                                startGroup:(dispatch_group_t)startGroup;

@end

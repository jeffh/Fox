#import "FOXLogicalProcess.h"
#import <dispatch/dispatch.h>
#import "FOXStateMachine.h"

@interface FOXLogicalProcess ()
// explicit strong to catch non-ARC
@property (atomic, strong) dispatch_group_t group;
@property (atomic, strong) dispatch_group_t startGroup;

@property (atomic) id initialModelState;
@property (atomic) id<FOXStateMachine> stateMachine;
@property (atomic, copy) NSArray *commands;
@property (atomic) id subject;
@end

@implementation FOXLogicalProcess

- (instancetype)initWithStartingModelState:(id)modelState
                              stateMachine:(id<FOXStateMachine>)stateMachine
                                  commands:(NSArray *)commands
                                   subject:(id)subject
                                     group:(dispatch_group_t)group
                                startGroup:(dispatch_group_t)startGroup
{
    self = [super init];
    if (self) {
        self.initialModelState = modelState;
        self.stateMachine = stateMachine;
        self.commands = commands;
        self.subject = subject;
        self.group = group;
        self.startGroup = startGroup;
    }
    return self;
}

- (void)run
{
    @autoreleasepool {
        [[[NSThread currentThread] threadDictionary] removeAllObjects];
        dispatch_group_wait(self.startGroup, DISPATCH_TIME_FOREVER);
        self.result = [self.stateMachine executeCommandSequence:self.commands
                                                        subject:self.subject
                                             startingModelState:self.initialModelState];
        dispatch_group_leave(self.group);
    }
}

@end

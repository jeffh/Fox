#import "FOXParallelGenerators.h"
#import "FOXGenerator.h"
#import "FOXRandom.h"
#import "FOXCoreGenerators.h"
#import "FOXNumericGenerators.h"
#import "FOXStateMachine.h"
#import "FOXStateMachineGenerators.h"
#import "FOXDictionary.h"
#import "FOXPrettyArray.h"
#import "FOXThread.h"


@interface FOXBlock : NSObject
@property (nonatomic) dispatch_group_t group;
@property (atomic, copy) id(^block)();
@property (atomic) id result;
@end

@implementation FOXBlock

- (instancetype)initWithGroup:(dispatch_group_t)group block:(id(^)())block
{
    self = [super init];
    if (self) {
        self.group = group;
        self.block = block;
    }
    return self;
}

- (void)run
{
    @autoreleasepool {
        fthread_yield();
        self.result = self.block();
        dispatch_group_leave(self.group);
    }
}

@end

FOX_EXPORT id<FOXGenerator> FOXExecuteParallelCommands(id<FOXStateMachine> stateMachine, id (^subjectFactory)(void)) {
    return FOXBind(FOXSeed(), ^id<FOXGenerator>(id<FOXRandom> prng) {
        return FOXMap(FOXParallelCommands(stateMachine), ^id(NSDictionary *parallelCommands) {
            @autoreleasepool {
                fthread_override(true);
                fthread_init();
                NSArray *prefixCommands = parallelCommands[@"command prefix"];
                NSArray *processCommands = parallelCommands[@"processes"];
                id subject = subjectFactory();
                id prefixModelState = [stateMachine modelStateFromCommandSequence:prefixCommands];
                NSArray *executedPrefix = [stateMachine executeCommandSequence:prefixCommands subject:subject];
                NSMutableArray *threads = [NSMutableArray array];
                NSMutableArray *blocks = [NSMutableArray array];
                dispatch_group_t group = dispatch_group_create();
                size_t numThreads = 0;
                for (NSArray *commands in processCommands) {
                    dispatch_group_enter(group);
                    FOXBlock *block = [[FOXBlock alloc] initWithGroup:group block:^id{
                        return [stateMachine executeCommandSequence:commands
                                                            subject:subject
                                                 startingModelState:prefixModelState];
                    }];
                    [blocks addObject:block];

                    NSThread *thread = [[NSThread alloc] initWithTarget:block
                                                               selector:@selector(run)
                                                                 object:nil];
                    thread.name = [NSString stringWithFormat:@"Fox Test Thread %lu", numThreads + 1];
                    [threads addObject:thread];
                    numThreads++;
                }
                [threads makeObjectsPerformSelector:@selector(start)];
                fthread_run_and_wait();
                fthread_override(false);

                [threads makeObjectsPerformSelector:@selector(cancel)];
                threads = nil;

                NSMutableArray *results = [blocks valueForKey:NSStringFromSelector(@selector(result))];
                for (id obj in results) {
                    NSCAssert(![obj isKindOfClass:[NSNull class]], @"Bad NULL");
                }
                NSArray *executedCommands = [FOXPrettyArray arrayWithArray:results];
                return [FOXDictionary dictionaryWithDictionary:@{@"command prefix": executedPrefix,
                                                                 @"processes": executedCommands}];
            }
        });
    });
}

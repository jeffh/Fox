#import "FOXScheduler.h"
#import "FOXThread.h"

@interface FOXScheduler ()
@property (nonatomic) id<FOXRandom> random;
@property (nonatomic) BOOL replaceThreads;
@property (nonatomic, copy) void (^block)();
@end

@implementation FOXScheduler

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return self;
}

- (instancetype)initWithRandom:(id<FOXRandom>)random
{
    return [self initWithRandom:random replaceThreads:YES];
}

- (instancetype)initWithRandom:(id<FOXRandom>)random
                replaceThreads:(BOOL)replaceThreads
{
    self = [super init];
    if (self) {
        self.random = random;
        self.replaceThreads = replaceThreads;
    }
    return self;
}

- (void)runAndWait:(void(^)())block
{
    fthread_init();
    fthread_override(self.replaceThreads);
    @try {
        NSThread *thread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector(runBlock)
                                                     object:nil];
        thread.name = @"Fox Bootstrap Thread";
        self.block = block;
        [thread start];
        fthread_run_and_wait(fthread_random, (__bridge void *)(self.random));
    }
    @finally {
        fthread_override(false);
    }
}

- (void)runBlock
{
    self.block();
}

@end

void FOXSchedulerYield(void) {
    fthread_yield();
}

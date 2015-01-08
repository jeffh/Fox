#import "FOXBlock.h"
#import "FOXThread.h"

@interface FOXBlock ()
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

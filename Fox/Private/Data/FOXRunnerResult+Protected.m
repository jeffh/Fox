#import "FOXRunnerResult+Protected.h"
#import <objc/runtime.h>

@implementation FOXRunnerResult (Protected)

const char *FOXRunnerResultFailingRoseTreeKey;

- (FOXRoseTree *)failingRoseTree
{
    return objc_getAssociatedObject(self, &FOXRunnerResultFailingRoseTreeKey);
}

- (void)setFailingRoseTree:(FOXRunnerResult *)failingRoseTree
{
    objc_setAssociatedObject(self, &FOXRunnerResultFailingRoseTreeKey, failingRoseTree, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

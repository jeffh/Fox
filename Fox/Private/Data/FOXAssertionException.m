#import "FOXAssertionException.h"

@implementation FOXAssertionException

- (instancetype)initWithPropertyResult:(FOXPropertyResult *)result
{
    self = [super initWithName:@"FOXAssertionException"
                        reason:@"Assertion Failed"
                      userInfo:@{@"FOXPropertyResult": result}];
    if (self) {
    }
    return self;
}

- (FOXPropertyResult *)result
{
    return self.userInfo[@"FOXPropertyResult"];
}

@end

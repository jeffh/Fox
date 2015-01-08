#import <Foundation/Foundation.h>

@interface FOXBlock : NSObject

- (instancetype)initWithGroup:(dispatch_group_t)group block:(id(^)())block;
- (void)run;

@end

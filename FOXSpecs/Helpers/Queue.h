#import <Foundation/Foundation.h>

@interface Queue : NSObject

- (instancetype)init;
- (void)addObject:(id)object;
- (id)removeObject;

@end

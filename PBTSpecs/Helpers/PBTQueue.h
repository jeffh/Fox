#import <Foundation/Foundation.h>

@interface PBTQueue : NSObject

- (instancetype)init;
- (void)addObject:(id)object;
- (id)removeObject;

@end

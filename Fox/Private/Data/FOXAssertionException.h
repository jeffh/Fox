#import <Foundation/Foundation.h>

@class FOXPropertyResult;

@interface FOXAssertionException : NSException

@property (nonatomic, readonly) FOXPropertyResult *result;

- (instancetype)initWithPropertyResult:(FOXPropertyResult *)result;

@end

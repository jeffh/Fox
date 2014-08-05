#import <Foundation/Foundation.h>


@interface PBTQuickCheckResult : NSObject

@property (nonatomic) BOOL succeeded;
@property (nonatomic) NSUInteger maxSize;
@property (nonatomic) NSUInteger numberOfTests;
@property (nonatomic) uint32_t seed;


// properties below are only filled when failures occur (succeeded = NO)
@property (nonatomic) NSUInteger failingSize;
@property (nonatomic) id failingArguments;
@property (nonatomic) NSException *failingException;         // only when exception occurs
@property (nonatomic) NSUInteger shrinkDepth;
@property (nonatomic) NSUInteger shrinkNodeWalkCount;
@property (nonatomic) id smallestFailingArguments;
@property (nonatomic) NSException *smallestFailingException; // only when exception occurs

- (NSString *)friendlyDescription;

@end

#import <Foundation/Foundation.h>


@interface FOXRunnerResult : NSObject

@property (nonatomic) BOOL succeeded;
@property (nonatomic) NSUInteger maxSize;
@property (nonatomic) NSUInteger numberOfTests;
@property (nonatomic) NSUInteger seed;


// properties below are only filled when failures occur (succeeded = NO)
@property (nonatomic) NSUInteger failingSize;
@property (nonatomic) id failingValue;
@property (nonatomic) NSException *failingException;         // only when exception occurs
@property (nonatomic) NSUInteger shrinkDepth;
@property (nonatomic) NSUInteger shrinkNodeWalkCount;
@property (nonatomic) id smallestFailingValue;
@property (nonatomic) NSException *smallestFailingException; // only when exception occurs

- (NSString *)friendlyDescription;
- (NSString *)singleLineDescriptionOfSmallestValue;

@end

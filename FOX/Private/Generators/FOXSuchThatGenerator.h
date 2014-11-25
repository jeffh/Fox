#import "FOXGenerator.h"


@interface FOXSuchThatGenerator : NSObject <FOXGenerator>

- (instancetype)initWithGenerator:(id<FOXGenerator>)generator predicate:(BOOL(^)(id generatedValue))predicate maxTries:(NSUInteger)maxTries;

@end

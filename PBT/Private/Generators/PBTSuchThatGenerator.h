#import "PBTGenerator.h"


@interface PBTSuchThatGenerator : NSObject <PBTGenerator>

- (instancetype)initWithGenerator:(id<PBTGenerator>)generator predicate:(BOOL(^)(id generatedValue))predicate maxTries:(NSUInteger)maxTries;

@end

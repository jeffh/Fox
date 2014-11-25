#import "FOXGenerator.h"

@protocol FOXSequence;


@interface FOXArrayGenerator : NSObject <FOXGenerator>

- (instancetype)initWithGenerators:(id<FOXSequence>)generators;

@end

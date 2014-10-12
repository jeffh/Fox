#import "PBTCommand.h"
#import "PBTStateTransition.h"


@interface PBTCommand ()
@property (nonatomic) id<PBTStateTransition> transition;
@property (nonatomic) id generatedValue;
@end


@implementation PBTCommand

- (instancetype)initWithTransition:(id<PBTStateTransition>)transition generatedValue:(id)generatedValue
{
    self = [super init];
    if (self) {
        self.transition = transition;
        self.generatedValue = generatedValue;
    }
    return self;
}

- (NSString *)description
{
    return [self.transition descriptionWithGeneratedValue:self.generatedValue];
}

@end

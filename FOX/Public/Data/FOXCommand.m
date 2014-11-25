#import "FOXCommand.h"
#import "FOXStateTransition.h"


@interface FOXCommand ()
@property (nonatomic) id<FOXStateTransition> transition;
@property (nonatomic) id generatedValue;
@end


@implementation FOXCommand

- (instancetype)initWithTransition:(id<FOXStateTransition>)transition generatedValue:(id)generatedValue
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

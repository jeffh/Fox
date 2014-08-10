#import "PBTCommand.h"


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
    return [NSString stringWithFormat:@"<perform (%@) with %@>",
            self.transition, self.generatedValue];
}

@end

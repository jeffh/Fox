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

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    FOXCommand *other = object;
    return ((self.transition == other.transition || [self.transition isEqual:other.transition])
            && (self.generatedValue == other.generatedValue || [self.generatedValue isEqual:other.generatedValue]));
}

- (NSString *)description
{
    return [self.transition descriptionWithGeneratedValue:self.generatedValue];
}

@end

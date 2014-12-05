#import "QueueAddTransition.h"
#import "Queue.h"
#import "FOX.h"


@implementation QueueAddTransition


- (BOOL)satisfiesPreConditionForModelState:(id)modalState
{
    return YES;
}

- (id<FOXGenerator>)generator
{
    return FOXInteger();
}

- (id)nextModelStateFromModelState:(NSArray *)previousModelState
                    generatedValue:(id)generatedValue
{
    return [previousModelState arrayByAddingObject:generatedValue];
}

- (id)objectReturnedByInvokingSubject:(id)subject
                       generatedValue:(id)generatedValue
{
    [subject addObject:generatedValue];
    return nil;
}

- (NSString *)descriptionWithGeneratedValue:(id)generatedValue {
    return [NSString stringWithFormat:@"addObject:%@", generatedValue];
}

@end

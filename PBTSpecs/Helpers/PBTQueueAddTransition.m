#import "PBTQueueAddTransition.h"
#import "PBTQueue.h"
#import "PBT.h"


@implementation PBTQueueAddTransition


- (BOOL)satisfiesPreConditionForModelState:(id)modalState
{
    return YES;
}

- (id<PBTGenerator>)generator
{
    return PBTInteger();
}

- (id)nextModelStateFromModelState:(NSArray *)previousModelState
                    generatedValue:(id)generatedValue
{
    return [previousModelState arrayByAddingObject:generatedValue];
}

- (id)objectFromAdvancingActualState:(id)actualState
                      generatedValue:(id)generatedValue
{
    [actualState addObject:generatedValue];
    return nil;
}

- (NSString *)descriptionWithGeneratedValue:(id)generatedValue {
    return [NSString stringWithFormat:@"addObject:%@", generatedValue];
}

@end

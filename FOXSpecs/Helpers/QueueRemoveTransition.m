#import "QueueRemoveTransition.h"
#import "FOX.h"
#import "Queue.h"


@implementation QueueRemoveTransition

- (BOOL)satisfiesPreConditionForModelState:(NSArray *)modalState
{
    return modalState.count > 0;
}

- (id<FOXGenerator>)generator
{
    return FOXInteger();
}

- (id)nextModelStateFromModelState:(NSArray *)previousModelState
                    generatedValue:(id)generatedValue
{
    return [previousModelState subarrayWithRange:NSMakeRange(1, previousModelState.count - 1)];
}

- (id)objectFromAdvancingActualState:(Queue *)actualState
                      generatedValue:(id)generatedValue
{
    return [actualState removeObject];
}

- (BOOL)satisfiesPostConditionInModelState:(NSArray *)currentModalState
                            fromModelState:(NSArray *)previousModalState
                               actualState:(Queue *)actualState
                            generatedValue:(id)generatedValue
               returnedObjectFromAdvancing:(id)actualStateResult
{
    id expectedObject = [previousModalState firstObject];
    return [expectedObject isEqual:actualStateResult];
}

- (NSString *)descriptionWithGeneratedValue:(id)generatedValue
{
    return NSStringFromSelector(@selector(removeObject));
}

@end

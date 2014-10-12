#import "PBTQueueRemoveTransition.h"
#import "PBT.h"
#import "PBTQueue.h"


@implementation PBTQueueRemoveTransition

- (BOOL)satisfiesPreConditionForModelState:(NSArray *)modalState
{
    return modalState.count > 0;
}

- (id<PBTGenerator>)generator
{
    return PBTInteger();
}

- (id)nextModelStateFromModelState:(NSArray *)previousModelState
                    generatedValue:(id)generatedValue
{
    return [previousModelState subarrayWithRange:NSMakeRange(1, previousModelState.count - 1)];
}

- (id)objectFromAdvancingActualState:(PBTQueue *)actualState
                      generatedValue:(id)generatedValue
{
    return [actualState removeObject];
}

- (BOOL)satisfiesPostConditionInModelState:(NSArray *)currentModalState
                            fromModelState:(NSArray *)previousModalState
                               actualState:(PBTQueue *)actualState
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

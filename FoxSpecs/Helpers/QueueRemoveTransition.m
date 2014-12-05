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

- (id)objectReturnedByInvokingSubject:(id)subject
                       generatedValue:(id)generatedValue
{
    return [subject removeObject];
}

- (BOOL)satisfiesPostConditionInModelState:(id)currentModelState
                            fromModelState:(id)previousModelState
                                   subject:(id)subject
                            generatedValue:(id)generatedValue
                   objectReturnedBySubject:(id)returnedObject
{
    id expectedObject = [previousModelState firstObject];
    return [expectedObject isEqual:returnedObject];
}

- (NSString *)descriptionWithGeneratedValue:(id)generatedValue
{
    return NSStringFromSelector(@selector(removeObject));
}

@end

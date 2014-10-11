#import "PBTStateTransition.h"


@interface PBTTransition : NSObject <PBTStateTransition>

@property (nonatomic, copy) id(^action)(id actualState, id generatedValue);
@property (nonatomic, copy) id(^nextState)(id modelState, id generatedValue);
@property (nonatomic, copy) BOOL(^precondition)(id modelState);
@property (nonatomic, copy) BOOL(^postcondition)(id modelState, id previousModelState, id actualState, id generatedValue, id returnedObject);
@property (nonatomic) id<PBTGenerator> generator;
@property (nonatomic, copy) NSString *name;

+ (instancetype)byCallingSelector:(SEL)selector
                    withGenerator:(id<PBTGenerator>)generator
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState;

+ (instancetype)forCallingSelector:(SEL)selector
                    nextModelState:(id (^)(id modelState, id generatedValue))nextState;

- (instancetype)initWithGenerator:(id<PBTGenerator>)generator
                           action:(id(^)(id actualState, id generatedValue))action
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState;

- (instancetype)initWithAction:(id(^)(id actualState, id generatedValue))advancer
                nextModelState:(id (^)(id modelState, id generatedValue))nextState;

@end

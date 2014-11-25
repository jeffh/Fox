#import "FOXStateTransition.h"


@interface FOXTransition : NSObject <FOXStateTransition>

@property (nonatomic, copy) id(^action)(id actualState, id generatedValue);
@property (nonatomic, copy) id(^nextState)(id modelState, id generatedValue);
@property (nonatomic, copy) BOOL(^precondition)(id modelState);
@property (nonatomic, copy) BOOL(^postcondition)(id modelState, id previousModelState, id actualState, id generatedValue, id returnedObject);
@property (nonatomic) id<FOXGenerator> generator;
@property (nonatomic, copy) NSString *name;

+ (instancetype)byCallingSelector:(SEL)selector
                    withGenerator:(id<FOXGenerator>)generator
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState;

+ (instancetype)byCallingSelector:(SEL)selector
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState;

- (instancetype)initWithGenerator:(id<FOXGenerator>)generator
                           action:(id(^)(id actualState, id generatedValue))action
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState;

- (instancetype)initWithAction:(id(^)(id actualState, id generatedValue))advancer
                nextModelState:(id (^)(id modelState, id generatedValue))nextState;

@end

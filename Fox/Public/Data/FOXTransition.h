#import "FOXStateTransition.h"


@interface FOXTransition : NSObject <FOXStateTransition>

@property (nonatomic, copy) id(^action)(id subject, id generatedValue);
@property (nonatomic, copy) id(^nextState)(id modelState, id generatedValue);
@property (nonatomic, copy) BOOL(^precondition)(id modelState);
@property (nonatomic, copy) BOOL(^postcondition)(id modelState, id previousModelState, id subject, id generatedValue, id returnedObject);
@property (nonatomic) id<FOXGenerator> generator;
@property (nonatomic, copy) NSString *name;

+ (instancetype)byCallingSelector:(SEL)selector
                    withGenerator:(id<FOXGenerator>)generator
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState;

+ (instancetype)byCallingSelector:(SEL)selector
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState;

- (instancetype)initWithGenerator:(id<FOXGenerator>)generator
                           action:(id(^)(id subject, id generatedValue))action
                   nextModelState:(id (^)(id modelState, id generatedValue))nextState;

- (instancetype)initWithAction:(id(^)(id subject, id generatedValue))advancer
                nextModelState:(id (^)(id modelState, id generatedValue))nextState;

@end

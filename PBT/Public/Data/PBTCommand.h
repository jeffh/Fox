#import <Foundation/Foundation.h>


@protocol PBTStateTransition;


@interface PBTCommand : NSObject

@property (nonatomic, readonly) id<PBTStateTransition> transition;
@property (nonatomic, readonly) id generatedValue;

- (instancetype)initWithTransition:(id<PBTStateTransition>)transition generatedValue:(id)generatedValue;

@end

#import <Foundation/Foundation.h>

@protocol FOXSequence;

@interface FOXSequenceEnumerator : NSEnumerator

- (id)initWithSequence:(id<FOXSequence>)sequence;

@property (nonatomic) id<FOXSequence> sequence;

@end

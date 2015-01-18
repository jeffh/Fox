#import "FOXRepeatedSequence.h"

@interface FOXRepeatedSequence ()
@property (nonatomic) id firstObject;
@property (nonatomic) id<FOXSequence> remainingSequence;
@end

@implementation FOXRepeatedSequence

- (instancetype)initWithObject:(id)object times:(NSUInteger)times
{
    self = [super init];
    if (self) {
        if (times > 0) {
            self.firstObject = object;
            // we must hold only remainingSequence since autoreleased objects
            // will cause problems inside objc foreaches
            self.remainingSequence = [[FOXRepeatedSequence alloc] initWithObject:object
                                                                           times:times - 1];
        }
        _count = times;
    }
    return self;
}

//#pragma mark - NSFastEnumeration
//
//- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
//                                  objects:(id __unsafe_unretained[])buffer
//                                    count:(NSUInteger)batchSize
//{
//    const unsigned long firstTimeState = 0;
//    const unsigned long processingState = 1;
//    if (state->state == firstTimeState) {
//        state->mutationsPtr = (__bridge void *)self;
//        state->extra[0] = (unsigned long)self;
//        state->state = processingState;
//    }
//    NSUInteger objectsCaptured = 0;
//    FOXRepeatedSequence *seq = (__bridge id)(void *)(state->extra[0]);
//    id object = seq.firstObject;
//
//    if (!object) {
//        return 0;
//    }
//
//    state->itemsPtr = buffer;
//
//    while (objectsCaptured < batchSize) {
//        *buffer++ = object;
//        objectsCaptured++;
//    }
//    return objectsCaptured;
//}

@end

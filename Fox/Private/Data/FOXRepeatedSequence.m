#import "FOXRepeatedSequence.h"
#import "FOXObjectiveCRepresentation.h"

@interface FOXRepeatedSequence ()
@property (nonatomic) id firstObject;
@property (nonatomic) id<FOXSequence> remainingSequence;
@end

@implementation FOXRepeatedSequence

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    id firstObject = [aDecoder decodeObjectForKey:@"firstObject"];
    NSUInteger times = [aDecoder decodeIntegerForKey:@"times"];
    return [self initWithObject:firstObject times:times];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.firstObject forKey:@"firstObject"];
    [aCoder encodeInteger:_count forKey:@"times"];
}

#pragma mark - Public

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

#pragma mark - FOXObjectiveCRepresentation

- (NSString *)objectiveCStringRepresentation
{
    return [NSString stringWithFormat:@"[FOXSequence sequenceWithObject:%@ times:%lu]",
            FOXRepr(self.firstObject),
            _count];
}

@end

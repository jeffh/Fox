#import "FOXStateMachineGenerator.h"
#import "FOXStateMachine.h"
#import "FOXStateTransition.h"
#import "FOXCoreGenerators.h"
#import "FOXArrayGenerators.h"
#import "FOXCommand.h"
#import "FOXRoseTree.h"
#import "FOXSequenceGenerator.h"

@interface FOXStateMachineGenerator ()
@property (nonatomic) id<FOXStateMachine> stateMachine;
@property (nonatomic) id initialModelState;
@property (nonatomic) NSNumber *minSize;
@property (nonatomic) NSNumber *maxSize;
@end


@implementation FOXStateMachineGenerator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithStateMachine:(id<FOXStateMachine>)stateMachine
{         
    return [self initWithStateMachine:stateMachine
                    initialModelState:[stateMachine initialModelState]
                              minSize:nil
                              maxSize:nil];
}

- (instancetype)initWithStateMachine:(id<FOXStateMachine>)stateMachine
                   initialModelState:(id)modelState
                             minSize:(NSNumber *)minSize
                             maxSize:(NSNumber *)maxSize
{
    self = [super init];
    if (self) {
        self.stateMachine = stateMachine;
        self.initialModelState = modelState;
        self.minSize = minSize;
        self.maxSize = maxSize;
    }
    return self;
}

- (FOXRoseTree *)lazyTreeWithRandom:(id<FOXRandom>)random maximumSize:(NSUInteger)maximumSize
{
    id<FOXGenerator> gen = [self naiveStateMachineGenerator];

    return [gen lazyTreeWithRandom:random maximumSize:maximumSize];
}

#pragma mark - Private

#pragma mark Naive State Machine Generator

- (id<FOXGenerator>)naiveStateMachineGenerator
{
    id<FOXGenerator> generator;
    if (!self.maxSize && !self.minSize) {
        generator = FOXArray([self commandGenerator]);
    } else if ([self.minSize isEqual:self.maxSize]) {
        NSUInteger size = [self.minSize unsignedIntegerValue];
        generator = FOXArrayOfSize([self commandGenerator], size);
    } else {
        NSUInteger minSize = [self.minSize unsignedIntegerValue];
        NSUInteger maxSize = [self.maxSize unsignedIntegerValue];
        generator = FOXArrayOfSizeRange([self commandGenerator], minSize, maxSize);
    }
    return FOXSuchThat(generator, ^BOOL(NSArray *commands) {
        id modelState = [self.stateMachine modelStateFromCommandSequence:commands
                                                      startingModelState:self.initialModelState];
        return modelState != nil;
    });
}

- (id<FOXGenerator>)commandGenerator
{
    NSMutableArray *frequencies = [NSMutableArray array];
    for (id<FOXStateTransition> transition in [self.stateMachine allTransitions]) {
        NSUInteger freq = 1;
        if ([transition respondsToSelector:@selector(frequency)]) {
            freq = [transition frequency];
        }
        [frequencies addObject:@[@(freq), FOXReturn(transition)]];
    }
    id<FOXGenerator> transitionsGenerator = FOXFrequency(frequencies);
    return FOXGenBind(transitionsGenerator, ^id<FOXGenerator>(FOXRoseTree *generatorTree) {
        id<FOXStateTransition> transition = generatorTree.value;
        id<FOXGenerator> argGenerator = nil;

        if ([transition respondsToSelector:@selector(generator)]) {
            argGenerator = [transition generator];
        } else {
            argGenerator = FOXReturn(@[]);
        }

        return FOXMap(FOXTuple(@[FOXReturn(transition), argGenerator]), ^id(NSArray *commandTuple) {
            return [[FOXCommand alloc] initWithTransition:commandTuple[0] generatedValue:commandTuple[1]];
        });
    });
}

@end

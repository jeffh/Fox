#import "PBTGenerator.h"
#import "PBTConcreteSequence.h"
#import "PBTLazySequence.h"
#import "PBTRandom.h"
#import "PBTRoseTree.h"


@interface PBTGenerator : NSObject <PBTGenerator>

@property (nonatomic, copy) PBTRoseTree *(^block)(id<PBTRandom>, NSUInteger);
@property (nonatomic, copy) NSString *name;

+ (instancetype)generatorWithName:(NSString *)name block:(PBTRoseTree *(^)(id<PBTRandom>, NSUInteger))block;
- (instancetype)initWithName:(NSString *)name block:(PBTRoseTree *(^)(id<PBTRandom>, NSUInteger))block;

@end


@implementation PBTGenerator

+ (instancetype)generatorWithName:(NSString *)name block:(PBTRoseTree *(^)(id<PBTRandom>, NSUInteger))block
{
    return [[self alloc] initWithName:name block:block];
}

- (instancetype)initWithName:(NSString *)name block:(PBTRoseTree *(^)(id<PBTRandom>, NSUInteger))block
{
    self = [super init];
    if (self) {
        self.name = name;
        self.block = [block copy];
    }
    return self;
}

- (PBTRoseTree *)lazyTreeWithRandom:(id<PBTRandom>)random maximumSize:(NSUInteger)maximumSize
{
    return self.block(random, maximumSize);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PBT:%@: %p>", self.name, self];
}

@end

PBT_EXPORT id<PBTGenerator> PBTWithName(NSString *name, id<PBTGenerator> generator) {
    NSCParameterAssert([generator isKindOfClass:[PBTGenerator class]]);
    ((PBTGenerator *)generator).name = [((PBTGenerator *)generator).name stringByAppendingFormat:@":%@", name];
    return generator;
}


#pragma mark - Generators

PBT_EXPORT id<PBTGenerator> PBTGenPure(PBTRoseTree *tree) {
    return [PBTGenerator generatorWithName:@"GenPure" block:^(id<PBTRandom> random, NSUInteger size) {
        return tree;
    }];
}

PBT_EXPORT id<PBTGenerator> PBTGenMap(id<PBTGenerator> generator,
                                      PBTRoseTree *(^mapfn)(PBTRoseTree *generatorTree)) {
    return [PBTGenerator generatorWithName:@"GenMap" block:^(id<PBTRandom> random, NSUInteger size) {
        return mapfn([generator lazyTreeWithRandom:random maximumSize:size]);
    }];
}

PBT_EXPORT id<PBTGenerator> PBTGenBind(id<PBTGenerator> generator,
                                       id<PBTGenerator> (^factory)(PBTRoseTree *generatorTree)) {
    return [PBTGenerator generatorWithName:@"GenBind" block:^(id<PBTRandom> random, NSUInteger size) {
        PBTRoseTree *innerTree = [generator lazyTreeWithRandom:random maximumSize:size];
        id<PBTGenerator> resultingGenerator = factory(innerTree);
        return [resultingGenerator lazyTreeWithRandom:random maximumSize:size];
    }];
}

PBT_EXPORT id<PBTGenerator> PBTMap(id<PBTGenerator> generator, id (^fn)(id value)) {
    return PBTWithName(@"Map", PBTGenMap(generator, ^PBTRoseTree *(PBTRoseTree *roseTree) {
        return [roseTree treeByApplyingBlock:fn];
    }));
};


PBT_EXPORT id<PBTGenerator> PBTReturn(id value) {
    return PBTWithName(@"Return", PBTGenPure([[PBTRoseTree alloc] initWithValue:value]));
}

// converts an array of generators to a generator that emits an array of generated values
PBT_EXPORT id<PBTGenerator> PBTSequenceGenerator(id<PBTSequence> generators) {
    return [generators objectByReducingWithSeed:PBTGenPure([[PBTRoseTree alloc] initWithValue:@[]]) reducer:^id(id<PBTGenerator> accumGenerator, id<PBTGenerator> generator) {
        return PBTGenBind(accumGenerator, ^id<PBTGenerator>(PBTRoseTree *generatorTree) {
           return PBTGenBind(generator, ^id<PBTGenerator>(PBTRoseTree *itemTree) {
               return PBTGenPure([PBTRoseTree mergedTreeFromRoseTrees:@[generatorTree, itemTree] merger:^id(NSArray *values){
                   if (values.count == 1) {
                       return values;
                   }
                   if (values[0] == [NSNull null]) {
                       return @[values[1]];
                   }
                   NSArray *accumValues = values[0];
                   id generatorValue = values[1];
                   return [accumValues arrayByAddingObject:generatorValue];
               }]);
           });
        });
    }];
}

PBT_EXPORT id<PBTGenerator> PBTSized(id<PBTGenerator> (^fn)(NSUInteger size)) {
    return [PBTGenerator generatorWithName:@"Sized" block:^(id<PBTRandom> random, NSUInteger size) {
        return [fn(size) lazyTreeWithRandom:random maximumSize:size];
    }];
}

PBT_EXPORT id<PBTSequence> _PBTHalfs(NSNumber *number) {
    if ([number compare:@0] == NSOrderedSame) {
        return nil;
    }
    return [[PBTConcreteSequence alloc] initWithObject:number
                                     remainingSequence:_PBTHalfs(@([number longLongValue] / 2))];
}

PBT_EXPORT id<PBTSequence> _PBTShrinkNumber(NSNumber *number) {
    return [_PBTHalfs(number) sequenceByApplyingBlock:^id(NSNumber *value) {
        return @([number longLongValue] - [value longLongValue]);
    }];
}

PBT_EXPORT PBTRoseTree *_PBTNumberRoseTree(NSNumber *number) {
    return [[PBTRoseTree alloc] initWithValue:number
                                     children:[_PBTShrinkNumber(number) sequenceByApplyingBlock:^id(NSNumber *value) {
        return _PBTNumberRoseTree(value);
    }]];
}

PBT_EXPORT id<PBTGenerator> PBTChoose(NSNumber *lower, NSNumber *upper) {
    return [PBTGenerator generatorWithName:[NSString stringWithFormat:@"Choose [%@, %@]", lower, upper]
                                     block:^(id<PBTRandom> random, NSUInteger size) {
        NSNumber *randValue = @((NSInteger)[random randomDoubleWithinMinimum:[lower doubleValue]
                                                                  andMaximum:[upper doubleValue]]);
        id<PBTSequence> seqOfTrees = _PBTShrinkNumber(randValue);
        seqOfTrees = [seqOfTrees sequenceByApplyingBlock:^id(id value) {
            return _PBTNumberRoseTree(value);
        }];
        PBTRoseTree *tree = [[PBTRoseTree alloc] initWithValue:randValue children:seqOfTrees];
        return [tree treeFilteredByBlock:^BOOL(NSNumber *value) {
            return [value compare:lower] != NSOrderedAscending
                && [value compare:upper] != NSOrderedDescending;
        }];
    }];
}

PBT_EXPORT id<PBTGenerator> PBTInteger(void) {
    return PBTWithName(@"Integer", PBTSized(^(NSUInteger sizeNumber){
        return PBTChoose(@(-((NSInteger)sizeNumber)), @(sizeNumber));
    }));
}

PBT_EXPORT id<PBTGenerator> _PBTNaturalInteger(void) {
    return PBTMap(PBTInteger(), ^id(NSNumber *number) {
        return @(ABS([number integerValue]));
    });
}

PBT_EXPORT id<PBTGenerator> PBTPositiveInteger(void) {
    return PBTWithName(@"PositiveInteger", _PBTNaturalInteger());
}

PBT_EXPORT id<PBTGenerator> PBTNegativeInteger(void) {
    return PBTWithName(@"NegativeInteger", PBTMap(_PBTNaturalInteger(), ^id(NSNumber *number) {
        return @(-[number integerValue]);
    }));
}

PBT_EXPORT id<PBTGenerator> PBTStrictPositiveInteger(void) {
    return PBTWithName(@"StrictPostiveInteger", PBTMap(_PBTNaturalInteger(), ^id(NSNumber *number) {
        return @([number integerValue] ?: 1);
    }));
}

PBT_EXPORT id<PBTGenerator> PBTStrictNegativeInteger(void) {
    return PBTWithName(@"StringNegativeInteger", PBTMap(_PBTNaturalInteger(), ^id(NSNumber *number) {
        return @(-([number integerValue] ?: 1));
    }));
}

PBT_EXPORT id<PBTSequence> _PBTRepeat(id value, NSUInteger times) {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:times];
    for (NSUInteger i = 0; i<times; i++) {
        [array addObject:value];
    }
    return [PBTConcreteSequence sequenceFromArray:array];
}

PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator) {
    id<PBTGenerator> sizeGenerator = PBTSized(^id<PBTGenerator>(NSUInteger size) {
        return PBTChoose(@0, @(size));
    });
    return PBTWithName(@"Array", PBTGenBind(sizeGenerator, ^id<PBTGenerator>(PBTRoseTree *sizeTree) {
        return PBTSequenceGenerator(_PBTRepeat(elementGenerator, [sizeTree.value integerValue]));
    }));
}

PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator, NSUInteger numberOfElements) {
    return PBTWithName(@"Array", PBTSequenceGenerator(_PBTRepeat(elementGenerator, numberOfElements)));
}

PBT_EXPORT id<PBTGenerator> PBTArray(id<PBTGenerator> elementGenerator,
                                     NSUInteger minimumNumberOfElements,
                                     NSUInteger maximumNumberOfElements) {
    id<PBTGenerator> sizeGenerator = PBTChoose(@(minimumNumberOfElements),
                                               @(maximumNumberOfElements + 1));
    return PBTWithName(@"Array", PBTGenBind(sizeGenerator, ^id<PBTGenerator>(PBTRoseTree *sizeTree) {
        id<PBTGenerator> sequenceGenerator = PBTSequenceGenerator(_PBTRepeat(elementGenerator, [sizeTree.value integerValue]));
        return PBTGenBind(sequenceGenerator, ^id<PBTGenerator>(PBTRoseTree *generatorTree) {
            return PBTGenPure([generatorTree treeFilteredByBlock:^BOOL(NSArray *elements) {
                NSUInteger count = [elements count];
                return count >= minimumNumberOfElements && count <= maximumNumberOfElements;
            }]);
        });
    }));
}

PBT_EXPORT id<PBTGenerator> PBTSet(id<PBTGenerator> elementGenerator) {
    return PBTMap(PBTArray(elementGenerator), ^id(NSArray *elements) {
        return [NSSet setWithArray:elements];
    });
}

PBT_EXPORT id<PBTGenerator> PBTSet(id<PBTGenerator> elementGenerator, NSUInteger numberOfElements) {
    return PBTMap(PBTArray(elementGenerator, numberOfElements), ^id(NSArray *elements) {
        return [NSSet setWithArray:elements];
    });
}

PBT_EXPORT id<PBTGenerator> PBTSet(id<PBTGenerator> elementGenerator,
                                   NSUInteger minimumNumberOfElements,
                                   NSUInteger maximumNumberOfElements);

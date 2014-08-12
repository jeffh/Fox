#import "PBTGenerator.h"
#import "PBTPropertyGenerators.h"
#import "PBTReporter.h"


@class PBTRunnerResult;


@interface PBTRunner : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init;
- (instancetype)initWithReporter:(id<PBTReporter>)reporter;
- (instancetype)initWithReporter:(id<PBTReporter>)reporter random:(id<PBTRandom>)random;

- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)numberOfTests
                                  property:(id<PBTGenerator>)property;
- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)numberOfTests
                                    forAll:(id<PBTGenerator>)values
                                      then:(PBTPropertyStatus (^)(id generatedValue))then;
- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                  property:(id<PBTGenerator>)property
                                      seed:(uint32_t)seed;
- (PBTRunnerResult *)resultForNumberOfTests:(NSUInteger)totalNumberOfTests
                                  property:(id<PBTGenerator>)property
                                      seed:(uint32_t)seed
                                   maxSize:(NSUInteger)maxSize;

@end



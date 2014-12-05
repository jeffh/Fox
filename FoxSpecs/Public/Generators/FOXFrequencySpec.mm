#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXFrequencySpec)

describe(@"FOXFrequency", ^{
    context(@"integration", ^{
        it(@"should choose generators probablistically when given an event probability", ^{
            id<FOXGenerator> gen = FOXFrequency(@[@[@1, FOXReturn(@1)],
                                                  @[@1, FOXReturn(@2)]]);
            __block NSUInteger option1Count = 0;
            __block NSUInteger option2Count = 0;
            FOXRunnerResult *result = [FOXSpecHelper resultForAll:gen then:^BOOL(id value) {
                if ([value isEqual:@1]) {
                    ++option1Count;
                    return YES;
                } else if ([value isEqual:@2]) {
                    ++option2Count;
                    return YES;
                } else {
                    NSCAssert(@"Unexpected value: %@", value);
                }
                return NO;
            }];

            result.succeeded should be_truthy;

            NSUInteger midPoint = [FOXSpecHelper numberOfTestsPerProperty] / 2;
            option1Count should be_close_to(option2Count).within(midPoint * 0.5);
        });

        it(@"should choose generators probablistically when having an uneven probability", ^{
            id<FOXGenerator> gen = FOXFrequency(@[@[@1, FOXReturn(@1)],
                                                  @[@5, FOXReturn(@2)]]);
            __block NSUInteger option1Count = 0;
            __block NSUInteger option2Count = 0;
            FOXRunnerResult *result = [FOXSpecHelper resultForAll:gen then:^BOOL(id value) {
                if ([value isEqual:@1]) {
                    ++option1Count;
                    return YES;
                } else if ([value isEqual:@2]) {
                    ++option2Count;
                    return YES;
                } else {
                    NSCAssert(@"Unexpected value: %@", value);
                }
                return NO;
            }];

            result.succeeded should be_truthy;
            option1Count should be_less_than(option2Count);
        });

        it(@"should shrink towards the given returned tuple", ^{
            id<FOXGenerator> gen = FOXFrequency(@[@[@0, FOXReturn(@1)],
                                                  @[@100, FOXReturn(@2)]]);

            FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:gen];
            result.succeeded should be_falsy;
            result.smallestFailingValue should equal(@2);
        });
    });
});
SPEC_END

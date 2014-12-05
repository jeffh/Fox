#import <Cedar.h>
#import "Fox.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXAnyObjectSpec)

describe(@"FOXAnyObject", ^{
    it(@"should generate any object", ^{
        NSMutableArray *classesSeen = [NSMutableArray array];
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXAnyObject() then:^BOOL(id value) {
            [classesSeen addObject:[value class]];
            return value != nil;
        }];
        result.succeeded should be_truthy;
        classesSeen.count should be_greater_than(1);
    });
});

describe(@"FOXAnyPrintableObject", ^{
    it(@"should generate any object", ^{
        NSMutableArray *classesSeen = [NSMutableArray array];
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXAnyPrintableObject() then:^BOOL(id value) {
            [classesSeen addObject:[value class]];
            return value != nil;
        }];
        result.succeeded should be_truthy;
        classesSeen.count should be_greater_than(1);
    });
});

SPEC_END

#import <Cedar/Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"
#import "FOXArrayGenerators.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(FOXArraySpec)

describe(@"FOXArray", ^{
    it(@"should be able to shrink to an empty array", ^{
        FOXRunnerResult *result = [FOXSpecHelper shrunkResultForAll:FOXArray(FOXInteger())];
        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@[]);
    });

    it(@"should be able to shrink elements of the array", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXArray(FOXInteger()) then:^BOOL(NSArray *values) {
            return [values count] <= 2;
        }];
        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@[@0, @0, @0]);
    });

    it(@"should be able to shrink elements of the nested array", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXArray(FOXArray(FOXInteger()))
                                                         then:^BOOL(NSArray *values) {
                                                             return [values count] <= 1;
                                                         }];
        result.succeeded should be_falsy;
        result.smallestFailingValue should equal(@[@[], @[]]);
    });

    it(@"should be able to return arrays of any size", ^{
        NSMutableSet *sizesSeen = [NSMutableSet set];
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXArray(FOXInteger()) then:^BOOL(id value) {
            BOOL isValid = YES;
            for (id element in value) {
                if (![element isKindOfClass:[NSNumber class]]) {
                    isValid = NO;
                }
            }
            [sizesSeen addObject:@([value count])];
            return isValid;
        }];
        result.succeeded should be_truthy;
        sizesSeen.count should be_greater_than(1);
    });

    it(@"should be able to return arrays of a given size", ^{
        Assert(forAll(FOXArrayOfSize(FOXInteger(), 5), ^BOOL(id value) {
            return [value count] == 5;
        }));
    });

    it(@"should be able to return arrays of a given size range", ^{
        FOXAssert(forAll(FOXArrayOfSizeRange(FOXInteger(), 5, 10), ^BOOL(id value) {
            NSUInteger count = [value count];
            return count >= 5 && count <= 10;
        }));
    });
});

SPEC_END

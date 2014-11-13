#import <Cedar/Cedar.h>
#import "PBT.h"
#import "PBTSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PBTGenericSpec)

describe(@"PBTSimpleType", ^{
    it(@"should be able to return any non-composite data type", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTSimpleType() then:^BOOL(id value) {
            return ([value isKindOfClass:[NSNumber class]] ||
                    [value isKindOfClass:[NSString class]]);
        }];
        result.succeeded should be_truthy;
    });
});

describe(@"PBTPrintableSimpleType", ^{
    it(@"should be able to return any non-composite object that is print-friendly", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTPrintableSimpleType() then:^BOOL(id value) {
            if ([value isKindOfClass:[NSNumber class]]) {
                return YES;
            } else if ([value isKindOfClass:[NSString class]]) {
                for (int i = 0; i < [value length]; i++) {
                    unichar chr = [value characterAtIndex:i];
                    if (chr < 32 || chr > 126) {
                        return NO;
                    }
                }
                return YES;
            }
            return NO;
        }];
        result.succeeded should be_truthy;
    });
});

describe(@"PBTCompositeType", ^{
    it(@"should be able to return any composite object using the item generator", ^{
        PBTRunnerResult *result = [PBTSpecHelper resultForAll:PBTCompositeType(PBTReturn(@1)) then:^BOOL(id value) {
            BOOL correctType = ([value isKindOfClass:[NSArray class]] ||
                                [value isKindOfClass:[NSSet class]]);
            if (!correctType) {
                return NO;
            }
            if ([value count] == 0) {
                return YES;
            }
            if ([value isKindOfClass:[NSArray class]]) {
                return [@1 isEqual:[value firstObject]];
            } else {
                return [@1 isEqual:[value anyObject]];
            }
        }];
        result.succeeded should be_truthy;
    });
});

SPEC_END

#import <Cedar.h>
#import "FOX.h"
#import "FOXSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FOXGenericSpec)

describe(@"FOXSimpleType", ^{
    it(@"should be able to return any non-composite data type", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXSimpleType() then:^BOOL(id value) {
            return ([value isKindOfClass:[NSNumber class]] ||
                [value isKindOfClass:[NSString class]]);
        }];
        result.succeeded should be_truthy;
    });
});

describe(@"FOXPrintableSimpleType", ^{
    it(@"should be able to return any non-composite object that is print-friendly", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXPrintableSimpleType() then:^BOOL(id value) {
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

describe(@"FOXCompositeType", ^{
    it(@"should be able to return any composite object using the item generator", ^{
        FOXRunnerResult *result = [FOXSpecHelper resultForAll:FOXCompositeType(FOXReturn(@1)) then:^BOOL(id value) {
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

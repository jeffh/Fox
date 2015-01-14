#import "FOXRaiseResult.h"
#import "FOXAssertionException.h"


FOX_EXPORT void FOXRaiseResult(FOXPropertyResult *result) {
    FOXAssertionException *exception = [[FOXAssertionException alloc] initWithPropertyResult:result];
    [exception raise];
}

#import "FOXMacros.h"

FOX_EXPORT NSString *FOXIndentStringWithWhitespace(NSString *string, NSString *whitespace);
FOX_EXPORT NSString *FOXWhitespace(NSUInteger indent);
FOX_EXPORT NSString *FOXIndentString(NSString *string, NSUInteger amount);
FOX_EXPORT NSString *FOXPrefix(NSString *prefix, NSString *string);
FOX_EXPORT NSString *FOXTrim(NSString *string);
FOX_EXPORT NSString *FOXDescription(id obj, NSUInteger indent);

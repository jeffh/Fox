#import "FOXStringUtil.h"


FOX_EXPORT NSString *FOXIndentStringWithWhitespace(NSString *string, NSString *whitespace) {
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    NSString *mostlyIndented = [lines componentsJoinedByString:[NSString stringWithFormat:@"\n%@", whitespace]];
    return mostlyIndented;
}

FOX_EXPORT NSString *FOXWhitespace(NSUInteger indent) {
    NSMutableString *whitespace = [NSMutableString string];
    for (NSUInteger i = 0; i < indent; i++) {
        [whitespace appendString:@"  "];
    }
    return whitespace;
}

FOX_EXPORT NSString *FOXIndentString(NSString *string, NSUInteger amount) {
    return FOXIndentStringWithWhitespace(string, FOXWhitespace(amount));
}

FOX_EXPORT NSString *FOXPrefix(NSString *prefix, NSString *string) {
    return [prefix stringByAppendingString:string];
}

FOX_EXPORT NSString *FOXTrim(NSString *string) {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

FOX_EXPORT NSString *FOXDescription(id obj, NSUInteger indent) {
    if ([obj respondsToSelector:@selector(descriptionWithLocale:indent:)]) {
        return [obj descriptionWithLocale:[NSLocale currentLocale] indent:indent];
    } else {
        return FOXIndentString([obj description], indent);
    }
}

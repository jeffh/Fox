#import "FOXObjectiveCRepresentation.h"

FOX_EXPORT NSString *FOXRepr(id obj) {
    if (!obj) {
        return nil;
    }
    if ([obj respondsToSelector:@selector(objectiveCStringRepresentation)]) {
        return [obj objectiveCStringRepresentation];
    }
    if ([obj isKindOfClass:[NSNull class]]) {
        return @"[NSNull null]";
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"@%@", obj];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"@\"%@\"", [[obj stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
                                                       stringByReplacingOccurrencesOfString:@"\""
                                                       withString:@"\\\""]];
    }
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableString *result = [NSMutableString stringWithFormat:@"@["];
        for (id item in obj) {
            [result appendFormat:@"%@,\n", FOXRepr(item)];
        }
        [result appendString:@"]"];
        return result;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableString *result = [NSMutableString stringWithFormat:@"@{"];
        for (id key in obj) {
            [result appendFormat:@"%@: %@,\n", FOXRepr(key), FOXRepr(obj[key])];
        }
        [result appendString:@"}"];
        return result;
    }
    [NSException raise:NSInvalidArgumentException format:@"object is not supported to dump: %@ (%@)",
     obj, NSStringFromClass([obj class])];
    return nil;
}

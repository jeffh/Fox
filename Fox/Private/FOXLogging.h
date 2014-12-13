#import "FOXMacros.h"

typedef NS_ENUM(NSUInteger, FOXLogLevel) {
    FOXLogLevelNone,
    FOXLogLevelError,
    FOXLogLevelWarning,
    FOXLogLevelDebug,
};

FOX_EXPORT void FOXLog(FOXLogLevel level, NSString *format, ...) NS_FORMAT_FUNCTION(2, 3);

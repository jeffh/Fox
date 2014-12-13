#import "FOXLogging.h"

static FOXLogLevel _foxLogLevel = FOXLogLevelNone;

FOX_EXPORT void FOXLog(FOXLogLevel level, NSString *format, ...) {
    if (level >= _foxLogLevel) {
        va_list args;
        va_start(args, format);
        printf("%s\n", [[NSString alloc] initWithFormat:format arguments:args].UTF8String);
        fflush(stdout);
        va_end(args);
    }
}

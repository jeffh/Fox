#import "FOXMacros.h"

FOX_EXPORT void logger(id target, SEL selector);
FOX_EXPORT BOOL FOXOverrideMsgSend(void (*handler)(id, SEL));
FOX_EXPORT BOOL FOXRestoreMsgSend(void);

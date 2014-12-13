#import "FOXMacros.h"

FOX_EXTERN kern_return_t FOXOverrideMsgSend(void (*handler)(NSInvocation *invocation));
FOX_EXTERN kern_return_t FOXRestoreMsgSend(void);

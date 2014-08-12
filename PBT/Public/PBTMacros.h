#import <Foundation/Foundation.h>

#define PBT_EXPORT FOUNDATION_EXPORT __attribute__((overloadable))

#if !PBT_NO_SHORTHAND
#define FORALL(GENERATOR, VAR, EXPR) ([PBTProperty forAll:(GENERATOR) then:^PBTPropertyStatus(VAR){ \
    return (EXPR);\
}])

#endif

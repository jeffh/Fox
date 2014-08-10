#import <Foundation/Foundation.h>

#define PBT_EXPORT FOUNDATION_EXPORT __attribute__((overloadable))

#if !PBT_NO_SHORTHAND
#define FORALL(GENERATOR, VAR, EXPR) ([PBTProperty forAll:(GENERATOR) then:^PBTPropertyStatus(VAR){ \
    return (EXPR);\
}])

#define CHECK(NUM_TESTS, PROPERTY) ([[PBTQuickCheck sharedInstance] checkWithNumberOfTests:(NUM_TESTS) property:(PROPERTY)])

#endif

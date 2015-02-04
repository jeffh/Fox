#import "FOXLimits.h"
#include <limits>

FOX_EXPORT float FOXFloatMax(void) {
    return std::numeric_limits<float>::max();
}

FOX_EXPORT float FOXFloatInfinity(void) {
    return std::numeric_limits<float>::infinity();
}

FOX_EXPORT float FOXFloatQNaN(void) {
    return std::numeric_limits<float>::quiet_NaN();
}

FOX_EXPORT double FOXDoubleMax(void) {
    return std::numeric_limits<double>::max();
}

FOX_EXPORT double FOXDoubleInfinity(void) {
    return std::numeric_limits<double>::infinity();
}

FOX_EXPORT double FOXDoubleQNaN(void) {
    return std::numeric_limits<double>::quiet_NaN();
}

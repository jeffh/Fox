#import "FOXMacros.h"


@protocol FOXGenerator;


/*! Generates values from a given dictionary template.
 *  The string are constant values while the values are generators.
 */
FOX_EXPORT id<FOXGenerator> FOXDictionary(NSDictionary *dictionaryTemplate);

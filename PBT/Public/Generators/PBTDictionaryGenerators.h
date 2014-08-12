#import "PBTMacros.h"


@protocol PBTGenerator;


/*! Generates values from a given dictionary template.
 *  The string are constant values while the values are generators.
 */
PBT_EXPORT id<PBTGenerator> PBTDictionary(NSDictionary *dictionaryTemplate);

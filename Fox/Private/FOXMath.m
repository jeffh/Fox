#import "FOXMath.h"
#import "FOXRandom.h"


void _combination(NSUInteger maxNumber,
                  NSUInteger originalCombinationSize,
                  NSUInteger combinationSize,
                  NSUInteger selectedDigits,
                  NSUInteger power,
                  void(^processor)(NSUInteger *combination, NSUInteger size)) {
    if (maxNumber < combinationSize + power) {
        return;
    }

    if (combinationSize == 0) {
        NSUInteger *combination = (NSUInteger *)alloca(sizeof(NSUInteger) * originalCombinationSize);
        NSUInteger i = 0;
        for (power = 0; power < maxNumber; power++) {
            if (selectedDigits & (1 << power)) {
                combination[i++] = power;
            }
        }
        processor(combination, i);
        return;
    }
    _combination(maxNumber, combinationSize, combinationSize - 1, selectedDigits | (1 << power), power + 1, processor);
    _combination(maxNumber, combinationSize, combinationSize, selectedDigits, power + 1, processor);
}

void eachCombination(NSUInteger numericSize, NSUInteger combinationSize, void(^processor)(NSUInteger *combination, NSUInteger size)) {
    _combination(numericSize, combinationSize, combinationSize, 0, 0, processor);
}

void _permutations(CFMutableArrayRef items, NSUInteger numItems, NSUInteger originalNumItems, BOOL (^processor)(NSArray *)) {
    int count = 0, index;
    CFTypeRef temp;
    while (1) {
        if (numItems > 2) {
            _permutations(items, numItems - 1, originalNumItems, processor);
        }
        if (count >= numItems - 1) {
            return;
        }

        index = (numItems & 1) ? 0 : count;
        count++;

        temp = CFArrayGetValueAtIndex(items, numItems - 1);
        CFArraySetValueAtIndex(items, numItems - 1, CFArrayGetValueAtIndex(items, index));
        CFArraySetValueAtIndex(items, index, temp);
        if (!processor((__bridge NSArray *)(items))) {
            return;
        }
    }
}

void eachPermutation(NSMutableArray *items, BOOL(^processor)(NSArray *permutation)) {
    if (!processor(items)) {
        return;
    }
    NSUInteger size = [items count];
    _permutations((__bridge CFMutableArrayRef)(items), size, size, processor);
}

FOX_EXPORT void foreverRandom(NSArray *items, id<FOXRandom> random, BOOL(^processor)(id item)) {
    BOOL continueProcessing = YES;
    NSUInteger maxCount = items.count - 1;
    while (continueProcessing) {
        NSUInteger index = [random randomIntegerWithinMinimum:0 andMaximum:maxCount];
        id item = items[index];
        continueProcessing = processor(item);
    }
}

import Foundation

// WARNING: please view this Swift API as ALPHA
//          it is subjected to change

// MARK: Array Generators

public func tuple(generators: FOXSequence) -> FOXGenerator {
    return FOXTupleOfGenerators(generators)
}

public func tuple(generators: [FOXGenerator]) -> FOXGenerator {
    return FOXTuple(generators)
}

public func array(elementGenerator: FOXGenerator) -> FOXGenerator {
    return FOXArray(elementGenerator)
}

public func array(elementGenerator: FOXGenerator, numberOfElements: UInt) -> FOXGenerator {
    return FOXArrayOfSize(elementGenerator, numberOfElements)
}

public func array(elementGenerator: FOXGenerator, minimumSize: UInt, maximumSize: UInt) -> FOXGenerator {
    return FOXArrayOfSizeRange(elementGenerator, minimumSize, maximumSize)
}

// MARK: Core Generators

public func genPure(tree: FOXRoseTree) -> FOXGenerator {
    return FOXGenPure(tree)
}

public func genMap(generator: FOXGenerator, mapfn: (FOXRoseTree) -> FOXRoseTree) -> FOXGenerator {
    return FOXGenMap(generator) { tree in
        return mapfn(tree!)
    }
}

public func map(generator: FOXGenerator, fn: (AnyObject?) -> AnyObject?) -> FOXGenerator {
    return FOXMap(generator) { value in
        return fn(value)
    }
}

public func bind(generator: FOXGenerator, fn: (AnyObject?) -> FOXGenerator) -> FOXGenerator {
    return FOXBind(generator) { value in
        return fn(value!)
    }
}

public func choose(lowerBound: Int, upperBound: Int) -> FOXGenerator {
    return FOXChoose(lowerBound, upperBound)
}

public func sized(factory: (UInt) -> FOXGenerator) -> FOXGenerator {
    return FOXSized(factory)
}

public func returns(value: AnyObject!) -> FOXGenerator {
    return FOXReturn(value)
}

public func suchThat(generator: FOXGenerator, maxTries: UInt = 3, predicate: (AnyObject!) -> Bool) -> FOXGenerator {
    return FOXSuchThatWithMaxTries(generator, predicate, maxTries)
}

public func oneOf(generators: [FOXGenerator]) -> FOXGenerator {
    return FOXOneOf(generators)
}

public func elements(elements: [AnyObject!]) -> FOXGenerator {
    return FOXElements(elements)
}

public func frequency(pairs: (UInt, FOXGenerator)...) -> FOXGenerator {
    var objcPairs: [AnyObject] = []
    for (freq, gen) in pairs {
        objcPairs.append([freq, gen])
    }
    return FOXFrequency(objcPairs)
}

public func resize(generator: FOXGenerator, newSize: UInt) -> FOXGenerator {
    return FOXResize(generator, newSize)
}

public func resize(generator: FOXGenerator, minimumSize: UInt, maximumSize: UInt) -> FOXGenerator {
    return FOXResizeRange(generator, minimumSize, maximumSize)
}

// MARK: Dictionary Generators

public func dictionary(template: NSDictionary) -> FOXGenerator {
    return FOXDictionary(template as! [NSObject : AnyObject])
}

// MARK: Numeric Generators

public func boolean() -> FOXGenerator {
    return FOXBoolean()
}

public func integer() -> FOXGenerator {
    return FOXInteger()
}

public func positiveInteger() -> FOXGenerator {
    return FOXPositiveInteger()
}

public func negativeInteger() -> FOXGenerator {
    return FOXNegativeInteger()
}

public func strictPositiveInteger() -> FOXGenerator {
    return FOXStrictPositiveInteger()
}

public func strictNegativeInteger() -> FOXGenerator {
    return FOXStrictNegativeInteger()
}

public func float() -> FOXGenerator {
    return FOXFloat()
}

public func double() -> FOXGenerator {
    return FOXDouble()
}

public func decimalNumber() -> FOXGenerator {
    return FOXDecimalNumber()
}

// MARK: Property Generators

public func forAll(dataType: FOXGenerator, then: (AnyObject!) -> Bool) -> FOXGenerator {
    return FOXForAll(dataType, then)
}

public func forSome(dataType: FOXGenerator, then: (AnyObject!) -> FOXPropertyStatus) -> FOXGenerator {
    return FOXForSome(dataType, then)
}

// MARK: Set Generators

public func set(elementGenerator: FOXGenerator) -> FOXGenerator {
    return FOXSet(elementGenerator)
}

// MARK: State Machine Generators

public func commands(stateMachine: FOXStateMachine) -> FOXGenerator {
    return FOXCommands(stateMachine)
}

public func executeCommands(stateMachine: FOXStateMachine, subjectFactory: () -> AnyObject!) -> FOXGenerator {
    return FOXExecuteCommands(stateMachine, subjectFactory)
}

public func executedSuccessfully(commands: NSArray) -> Bool {
    return FOXExecutedSuccessfully(commands as! [AnyObject])
}

// MARK: String Generators

public func character() -> FOXGenerator {
    return FOXCharacter()
}

public func alphabeticalCharacter() -> FOXGenerator {
    return FOXAlphabeticalCharacter()
}

public func numericCharacter() -> FOXGenerator {
    return FOXNumericCharacter()
}

public func alphanumericCharacter() -> FOXGenerator {
    return FOXAlphanumericCharacter()
}

public func asciiCharacter() -> FOXGenerator {
    return FOXAsciiCharacter()
}

public func string() -> FOXGenerator {
    return FOXString()
}

public func string(length: UInt) -> FOXGenerator {
    return FOXStringOfLength(length);
}

public func string(minimumLength: UInt, maximumLength: UInt) -> FOXGenerator {
    return FOXStringOfLengthRange(minimumLength, maximumLength);
}

public func asciiString() -> FOXGenerator {
    return FOXAsciiString()
}

public func asciiString(length: UInt) -> FOXGenerator {
    return FOXAsciiStringOfLength(length)
}

public func asciiString(minimumLength: UInt, maximumLength: UInt) -> FOXGenerator {
    return FOXAsciiStringOfLengthRange(minimumLength, maximumLength)
}

public func alphabeticalString() -> FOXGenerator {
    return FOXAlphabeticalString()
}

public func alphabeticalString(length: UInt) -> FOXGenerator {
    return FOXAlphabeticalStringOfLength(length)
}

public func alphabeticalString(minimumLength: UInt, maximumLength: UInt) -> FOXGenerator {
    return FOXAlphabeticalStringOfLengthRange(minimumLength, maximumLength)
}

public func alphanumericString() -> FOXGenerator {
    return FOXAlphanumericString()
}

public func numericString() -> FOXGenerator {
    return FOXNumericString()
}

// MARK: Generic Generators

public func simpleType() -> FOXGenerator {
    return FOXSimpleType()
}

public func printableSimpleType() -> FOXGenerator {
    return FOXPrintableSimpleType()
}

public func compositeType(elementGenerator: FOXGenerator) -> FOXGenerator {
    return FOXCompositeType(elementGenerator)
}

public func anyObject() -> FOXGenerator {
    return FOXAnyObject()
}

public func anyPrintableObject() -> FOXGenerator {
    return FOXAnyPrintableObject()
}


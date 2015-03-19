import Foundation
import XCTest

public func Assert(
    property: FOXGenerator,
    seed: UInt? = nil,
    numberOfTests: UInt? = nil,
    maximumSize: UInt? = nil,
    file: String = __FILE__,
    line: UInt = __LINE__) {

        let theSeed = (seed != nil) ? seed! : FOXGetSeed()
        let numTests = (numberOfTests != nil) ? numberOfTests! : FOXGetNumberOfTests()
        let maxSize = (maximumSize != nil) ? maximumSize! : FOXGetMaximumSize()

        var runner = FOXRunner.assertInstance()
        var result = runner.resultForNumberOfTests(numTests,
            property: property,
            seed: theSeed,
            maxSize: maxSize)

        if !result.succeeded {
            XCTFail("Property failed with: \(result.singleLineDescriptionOfSmallestValue())",
                file: file, line: line)
        }
}

import Foundation
import XCTest

public func Assert(
    property: FOXGenerator,
    seed: UInt? = nil,
    numberOfTests: UInt? = nil,
    maximumSize: UInt? = nil,
    file: StaticString = #file,
    line: UInt = #line) {

        let theSeed = (seed != nil) ? seed! : FOXGetSeed()
        let numTests = (numberOfTests != nil) ? numberOfTests! : FOXGetNumberOfTests()
        let maxSize = (maximumSize != nil) ? maximumSize! : FOXGetMaximumSize()

        let runner = FOXRunner.assertInstance()
        let result = runner.resultForNumberOfTests(numTests,
            property: property,
            seed: theSeed,
            maxSize: maxSize)

        if !result.succeeded {
            XCTFail("Property failed with: \(result.singleLineDescriptionOfSmallestValue())",
                file: file, line: line)
        }
}

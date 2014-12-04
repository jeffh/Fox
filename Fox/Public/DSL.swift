import Foundation

public func Assert(
    property: FOXGenerator,
    seed: UInt32? = nil,
    numberOfTests: UInt? = nil,
    maximumSize: UInt? = nil,
    file: String = __FILE__,
    line: UInt = __LINE__) {

        let theSeed = (seed != nil) ? seed! : UInt32(time(nil))
        let numTests = (numberOfTests != nil) ? numberOfTests! : FOXGetNumberOfTests()
        let maxSize = (maximumSize != nil) ? maximumSize! : FOXGetMaximumSize()

        _FOXAssert(property, "", file, UInt32(line), FOXOptions(seed: theSeed, numberOfTests: numTests, maximumSize: maxSize))
}

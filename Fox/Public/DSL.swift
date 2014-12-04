import Foundation

public func Assert(
    property: FOXGenerator,
    seed: UInt32? = nil,
    numberOfTests: UInt = FOXDefaultNumberOfTests,
    maximumSize: UInt = FOXDefaultMaximumSize,
    file: String = __FILE__,
    line: UInt = __LINE__) {

        let theSeed = (seed != nil) ? seed! : UInt32(time(nil))

        _FOXAssert(property, "", file, UInt32(line), FOXOptions(seed: theSeed, numberOfTests: numberOfTests, maximumSize: maximumSize))
}

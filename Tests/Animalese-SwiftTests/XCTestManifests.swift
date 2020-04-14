import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Animalese_SwiftTests.allTests),
    ]
}
#endif

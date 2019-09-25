import XCTest
@testable import XCTestExtensions

final class XCTestExtensionsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(XCTestExtensions().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

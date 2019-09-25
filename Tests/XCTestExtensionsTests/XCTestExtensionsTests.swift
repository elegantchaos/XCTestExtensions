import XCTest
@testable import XCTestExtensions

final class XCTestExtensionsTests: XCTestCase {
    func testExample() {
        let url = temporaryFile(named: "test", extension: "blah")
        XCTAssertEqual(url.lastPathComponent, "test.blah")
    }
}

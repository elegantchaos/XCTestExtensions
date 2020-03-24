// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import XCTestExtensions

final class XCTestExtensionsTests: XCTestCase {
    func testTemporaryFile() {
        let url = temporaryFile(named: "test", extension: "blah")
        XCTAssertEqual(url.lastPathComponent, "test.blah")
    }
    
    func testTestBundle() {
        let bundle = testBundle
        XCTAssertEqual(bundle.bundleURL.pathExtension, "xctest")
    }
    
    func testProductsDirectory() {
        let ourURL = productsDirectory.appendingPathComponent(testBundleName).appendingPathExtension("xctest")
        XCTAssertTrue(FileManager.default.fileExists(atPath: ourURL.path))
    }
    
    func testResources() {
        let string = testString(named: "Test", withExtension: "json")
        XCTAssertEqual(string, """
            {
                "foo": "bar"
            }
            """
        )
    }
    
    func testFlags() {
        XCTAssertFalse(testFlag("foo"))
        XCTAssertTrue(testFlag("NSUnbufferedIO")) // TODO: this might be flaky - not sure we can rely on it always being set
        print(ProcessInfo.processInfo.environment)
    }
}

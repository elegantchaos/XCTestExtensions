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
    
    func testTestBundleName() {
        XCTAssertEqual(testBundleName, "XCTestExtensionsTests")
    }
    
    func testTestBundle() {
        let url = testBundle.bundleURL
        #if !os(Linux)
        XCTAssertEqual(url.pathExtension, "xctest")
        #else
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(testBundleName).appendingPathExtension("xctest").path))
        #endif
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
        
        let environment = ProcessInfo.processInfo.environment
        if environment["GITHUB_ACTIONS"] != nil {
            XCTAssertTrue(testFlag("GITHUB_ACTIONS")) // this should work when we're testing with GH actions
        } else if environment["NSUnbufferedIO"] != nil {
            XCTAssertTrue(testFlag("NSUnbufferedIO")) // this should work when testing from Xcode
        }
    }
}

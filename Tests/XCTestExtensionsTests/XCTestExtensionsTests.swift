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
        print(bundle.bundleURL)
        print(try! FileManager.default.contentsOfDirectory(atPath: bundle.bundleURL.path))
        #if !os(Linux)
        XCTAssertEqual(bundle.bundleURL.pathExtension, "xctest")
        #endif
    }
    
    func testProductsDirectory() {
        print(try! FileManager.default.contentsOfDirectory(atPath: productsDirectory.path))
        #if !os(Linux)
        let ourURL = productsDirectory.appendingPathComponent(testBundleName).appendingPathExtension("xctest")
        XCTAssertTrue(FileManager.default.fileExists(atPath: ourURL.path))
        #endif
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

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
        let names = ["XCTestExtensionsTests", "XCTestExtensionsPackageTests"] // on Linux and Swift 5.2+, the bundle name seems to have Package added
        XCTAssertTrue(names.contains(testBundleName))
    }
    
    func testTestBundle() {
        let url = testBundle.bundleURL
        #if !os(Linux)
        XCTAssertEqual(url.pathExtension, "xctest")
        #else
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(testBundleName).appendingPathExtension("xctest")))
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
    
    func testResults() {
        struct ExampleError: Error { }
        typealias ExampleResult = Result<Int, Error>
        
        let ok1 = ExampleResult.success(1)
        
        XCTAssertSuccess(ok1) {
            XCTAssertEqual($0, 1)
        }
        
        XCTAssertEqual(ok1, ExampleResult.success(1))
        XCTAssertNotEqual(ok1, ExampleResult.success(2))
        XCTAssertNotEqual(ok1, ExampleResult.failure(ExampleError()))

        let failed = ExampleResult.failure(ExampleError())
        
        XCTAssertFailure(failed) {
            XCTAssertTrue($0 is ExampleError)
        }
        XCTAssertEqual(failed, ExampleResult.failure(ExampleError()))
        XCTAssertNotEqual(failed, ExampleResult.failure(NSError(domain: "test", code: 123, userInfo: [:]) ))
        XCTAssertNotEqual(failed, ExampleResult.success(1))

    }
    
    func testCollections() {
        XCTAssertEmpty([])
    }
}

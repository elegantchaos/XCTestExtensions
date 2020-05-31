// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import XCTestExtensions

extension Error {
    var description: String { localizedDescription }
}

struct ExampleError: Error, CustomStringConvertible, Equatable {
    var description: String
}

typealias ExampleResult = Result<Int, ExampleError>

extension Result: Matchable where Success: Matchable, Failure: Matchable {
    public func matches(_ other: Result<Success, Failure>) -> Bool {
        if case let .success(d1) = self, case let .success(d2) = other {
            return d1.matches(d2)
        } else if case let .failure(e1) = self, case let .failure(e2) = other {
            return e1.matches(e2)
        } else {
            return false
        }
    }
}

final class MatchingTests: XCTestCase {
    func testEquatable() {
        XCTAssertTrue(matches(1, 1))
        XCTAssertFalse(matches(1, 2))
    }
    
    func testDescribable() {
        let x: [String:Any] = ["foo": "bar"]
        XCTAssertTrue(matches(x, ["foo": "bar"]))
        XCTAssertFalse(matches(x, ["foo": "baz"]))
    }
    
    func testResult() {
        
        let ok1 = ExampleResult.success(1)
        
        XCTAssertTrue(matches(ok1, ExampleResult.success(1)))
        XCTAssertNotEqual(ok1, ExampleResult.success(2))
        XCTAssertNotEqual(ok1, ExampleResult.failure(ExampleError()))

        let failed = ExampleResult.failure(ExampleError())
        XCTAssertEqual(failed, ExampleResult.failure(ExampleError()))
        XCTAssertNotEqual(failed, ExampleResult.failure(NSError(domain: "test", code: 123, userInfo: [:]) ))
        XCTAssertNotEqual(failed, ExampleResult.success(1))


    }
}

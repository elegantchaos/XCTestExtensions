// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if !os(watchOS)
import XCTest

/// Assert that a result is a failure.
/// - Parameter result: The result to check.
/// - Parameter message: A message to print if the assertion fails.
/// - Parameter expectation: An expectation to fullfill if the assertion fails, or if it succeeds with no continuation provided.
/// - Parameter continuation: A continuation method to call if the assertion succeeded.
///
/// In an asynchronous setting, you're typically waiting for an expectation to be fullfilled before ending the test.
/// If this assertion failed, you may want to exit the tests early, which is why we accept an expectation to fullfill.
/// Conversely if the assertion succeeds, you may want to perform extra work, which is why we accept a continuation block.
/// If no continuation is provided, but an expectation was provided, we call the expectation if the assertion succeeds, on the
/// assumption that there's nothing more to do and we want to signal that the test is done.

public func XCTAssertFailure<S,F>(_ result: Result<S,F>, message: String = "Unexpected Success", expectation: XCTestExpectation? = nil, continuation: ((F) -> Void)? = nil) {
    switch result {
    case .success(let success):
        XCTFail("\(message): \(success)")
        expectation?.fulfill()
    case .failure(let error):
        if let continuation = continuation {
            continuation(error)
        } else {
            expectation?.fulfill()
        }
    }
}

/// Assert that a result is a success.
/// - Parameter result: The result to check.
/// - Parameter message: A message to print if the assertion fails.
/// - Parameter expectation: An expectation to fullfill if the assertion fails, or if it succeeds with no continuation provided.
/// - Parameter continuation: A continuation method to call if the assertion succeeded.
///
/// In an asynchronous setting, you're typically waiting for an expectation to be fullfilled before ending the test.
/// If this assertion failed, you may want to exit the tests early, which is why we accept an expectation to fullfill.
/// Conversely if the assertion succeeds, you may want to perform extra work, which is why we accept a continuation block.
/// If no continuation is provided, but an expectation was provided, we call the expectation if the assertion succeeds, on the
/// assumption that there's nothing more to do and we want to signal that the test is done.

public func XCTAssertSuccess<S,F>(_ result: Result<S,F>, message: String = "Failure", expectation: XCTestExpectation? = nil, continuation: ((S) -> Void)? = nil) {
    switch result {
    case .failure(let error):
        XCTFail("\(message): \(error)")
        expectation?.fulfill()
    case .success(let success):
        if let continuation = continuation {
            continuation(success)
        } else {
            expectation?.fulfill()
        }
    }
}


#if os(macOS) || os(Linux)
/// Assert that the result of running an external executable matches expected values.
public func XCTAssertResult(_ result: XCTestRunner.Result, status: Int32, stdout: String, stderr: String, ignoringWhitespace: Bool = true, file: StaticString = #file, line: UInt = #line) {
    switch result {
        case .ok(let out, let err):
            XCTAssertEqual(status, 0)
            XCTAssertEqualLineByLine(out, stdout, ignoringWhitespace: ignoringWhitespace, file: file, line: line)
            XCTAssertEqualLineByLine(err, stderr, ignoringWhitespace: ignoringWhitespace, file: file, line: line)
        
    case .failed(let code, let out, let err):
            XCTAssertEqual(code, status)
            XCTAssertEqualLineByLine(out, stdout, ignoringWhitespace: ignoringWhitespace, file: file, line: line)
            XCTAssertEqualLineByLine(err, stderr, ignoringWhitespace: ignoringWhitespace, file: file, line: line)

    case .launchError(let error):
        XCTFail("launch error \(error)", file: file, line: line)
    }
}
#endif

#endif

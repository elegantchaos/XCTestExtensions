// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(Combine)

import Combine
import XCTest

@available(macOS 10.15, *) public extension XCTestCase {

    /// Wait for a publisher to emit a value
    ///
    /// - Parameters:
    ///   - timeout: Time to wait before giving up.
    ///   - action: An action to perform, which is expected to result in the publisher emitting a value.
    func waitForValue<P>(_ publisher: P, timeout: TimeInterval = 0.1, action: @escaping () -> ()) where P: Publisher, P.Failure == Never {
        let expectation = XCTestExpectation()
        let watcher = publisher.sink() { _ in
            expectation.fulfill()
        }
        action()
        wait(for: [expectation], timeout: timeout)
        _ = watcher.hashValue // pointless use of watcher, to suppress 'not used' warning and ensure it stays in scope long enough
    }

    /// Wait for a publisher NOT to emit a value
    /// A little counter-intuitive this one, and only useful in limited situations.
    /// It will perform an action and then wait a short time to see if the publisher emits a value.
    /// If a value is emitted, we call XCFail.
    ///
    /// - Parameters:
    ///   - timeout: Time to wait before giving up.
    ///   - action: An action to perform, which is expected to result in the publisher not emitting a value.
    func waitForNoValue<P>(_ publisher: P, timeout: TimeInterval = 0.1, action: @escaping () -> ()) where P: Publisher, P.Failure == Never {
        let expectation = XCTestExpectation()
        let watcher = publisher.sink() { _ in
            XCTFail("Unexpected value")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + timeout / 2.0) {
            expectation.fulfill()
        }

        action()
        wait(for: [expectation], timeout: timeout)
        _ = watcher.hashValue // pointless use of watcher, to suppress 'not used' warning and ensure it stays in scope long enough
    }

    /// Wait for an observed object to change.
    ///
    /// - Parameters:
    ///   - timeout: Time to wait before giving up.
    ///   - action: An action to perform, which is expected to result in the object changing.
    func waitForChange<O>(_ object: O, timeout: TimeInterval = 0.1, action: @escaping () -> ()) where O: ObservableObject {
        waitForValue(object.objectWillChange, timeout: timeout, action: action)
    }

    /// Check that some action doesn't cause an observed object to change.
    /// - Parameters:
    ///   - timeout: Time to wait before giving up.
    ///   - action: An action to perform, which is expected to result in the object NOT changing.
    func waitForChangeToFail<O>(_ object: O, timeout: TimeInterval = 0.1, _ action: @escaping () -> ()) where O: ObservableObject {
        waitForNoValue(object.objectWillChange, timeout: timeout, action: action)
    }
}

#endif

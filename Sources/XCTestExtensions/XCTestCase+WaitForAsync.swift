// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/01/2021.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

public extension XCTestCase {
    typealias Action = (@escaping () -> ()) -> ()
    
    /// Wait for an asyncronous action to finish.
    ///
    /// - Parameters:
    ///   - timeout: Time to wait before giving up.
    ///   - action: The action to perform. Passed a function to call when the action has completed.
    func waitForAsync(timeout: TimeInterval = 1.0, _ action: @escaping Action) {
        let expectation = XCTestExpectation(description: "action called completion")
        action({ expectation.fulfill() })
        wait(for: [expectation], timeout: timeout)
    }
}

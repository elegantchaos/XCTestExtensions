// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

/// The status of an asynchronous test.
public enum XCTestStatus {
    case unknown
    case failed
    case ok
}

public protocol XCTestMonitor {
    var status: XCTestStatus { get }
    func allChecksDone()
    func checkFailed()
    func check(count: Int, expected: Int)
}

/// Helper used to check and report on the status of an asynchronous test.
///
open class SimpleTestMonitor<T>: XCTestMonitor {

     public typealias Checker = (T) -> Void
     public var status: XCTestStatus = .unknown
     public let expectation: XCTestExpectation
     public let checker: Checker
     
     public init(expectation: XCTestExpectation, checker: @escaping Checker) {
         self.expectation = expectation
         self.checker = checker
     }
     
     public func allChecksDone() {
         if status == .unknown {
             status = .ok
             self.expectation.fulfill()
         }
     }
     
     public func checkFailed() {
         if status == .unknown {
             status = .failed
             expectation.fulfill()
         }
     }
     
     public func check(count: Int, expected: Int) {
         if status == .unknown {
             if count != expected {
                 status = .failed
                 XCTFail("\(count) != \(expected)")
                 expectation.fulfill()
             }
         }
     }
 }

open class WrappedTestMonitor<MonitorType: XCTestMonitor>: XCTestMonitor {
    public let wrappedMonitor: MonitorType
    
    public init(wrappedMonitor: MonitorType) {
        self.wrappedMonitor = wrappedMonitor
    }
    
    public var status: XCTestStatus { return wrappedMonitor.status }
    public func allChecksDone() { wrappedMonitor.allChecksDone() }
    public func checkFailed() { wrappedMonitor.checkFailed() }
    public func check(count: Int, expected: Int) { wrappedMonitor.check(count: count, expected: expected) }
}

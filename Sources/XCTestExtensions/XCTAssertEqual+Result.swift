// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if !os(watchOS)
import XCTest
import Foundation

public func XCTAssertEqual<T>(_ r1: Result<T, Error>, _ r2: Result<T, Error>, file: StaticString = #file, line: UInt = #line) where T: Equatable, T: CustomStringConvertible {
    if case let .success(d1) = r1, case let .success(d2) = r2 {
        XCTAssertEqual(d1, d2, file: file, line: line)
    } else if case let .failure(e1) = r1, case let .failure(e2) = r2 {
        XCTAssertEqual(e1.localizedDescription, e2.localizedDescription, file: file, line: line)
    } else {
        XCTFail("\(r1) != \(r2)", file: file, line: line)
    }
}

public func XCTAssertEqual<T>(_ r1: Result<T, Error>, _ r2: Result<T, Error>, file: StaticString = #file, line: UInt = #line) where T: Equatable {
    if case let .success(d1) = r1, case let .success(d2) = r2 {
        XCTAssertEqual(d1, d2, file: file, line: line)
    } else if case let .failure(e1) = r1, case let .failure(e2) = r2 {
        XCTAssertEqual(e1.localizedDescription, e2.localizedDescription, file: file, line: line)
    } else {
        XCTFail("\(r1) != \(r2)", file: file, line: line)
    }
}

public func XCTAssertEqual<T>(_ r1: Result<T, Error>, _ r2: Result<T, Error>, file: StaticString = #file, line: UInt = #line) where T: CustomStringConvertible {
    if case let .success(d1) = r1, case let .success(d2) = r2 {
        XCTAssertEqual(d1.description, d2.description, file: file, line: line)
    } else if case let .failure(e1) = r1, case let .failure(e2) = r2 {
        XCTAssertEqual(e1.localizedDescription, e2.localizedDescription, file: file, line: line)
    } else {
        XCTFail("\(r1) != \(r2)", file: file, line: line)
    }
}

public func XCTAssertNotEqual<T>(_ r1: Result<T, Error>, _ r2: Result<T, Error>, file: StaticString = #file, line: UInt = #line) where T: Equatable, T: CustomStringConvertible {
    if case let .success(d1) = r1, case let .success(d2) = r2 {
        XCTAssertNotEqual(d1, d2, file: file, line: line)
    } else if case let .failure(e1) = r1, case let .failure(e2) = r2 {
        XCTAssertNotEqual(e1.localizedDescription, e2.localizedDescription, file: file, line: line)
    }
}

public func XCTAssertNotEqual<T>(_ r1: Result<T, Error>, _ r2: Result<T, Error>, file: StaticString = #file, line: UInt = #line) where T: Equatable {
    if case let .success(d1) = r1, case let .success(d2) = r2 {
        XCTAssertNotEqual(d1, d2, file: file, line: line)
    } else if case let .failure(e1) = r1, case let .failure(e2) = r2 {
        XCTAssertNotEqual(e1.localizedDescription, e2.localizedDescription, file: file, line: line)
    }
}

public func XCTAssertNotEqual<T>(_ r1: Result<T, Error>, _ r2: Result<T, Error>, file: StaticString = #file, line: UInt = #line) where T: CustomStringConvertible {
    if case let .success(d1) = r1, case let .success(d2) = r2 {
        XCTAssertNotEqual(d1.description, d2.description, file: file, line: line)
    } else if case let .failure(e1) = r1, case let .failure(e2) = r2 {
        XCTAssertNotEqual(e1.localizedDescription, e2.localizedDescription, file: file, line: line)
    }
}
#endif

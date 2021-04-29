// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

public func XCTAssert<T>(_ value: T, matches other: T, options: MatchOptions = .default, file: StaticString = #file, line: UInt = #line) where T: Matchable {
    do {
        try value.matches(other, context: MatchContext(options: options, file: file, line: line))
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}

public func XCTAssert<T, I>(_ key: KeyPath<T, I>, of value: T, matches other: T, options: MatchOptions = .default, file: StaticString = #file, line: UInt = #line) where I: Matchable {
    do {
    try value[keyPath: key].matches(other[keyPath: key], context: MatchContext(options: options, file: file, line: line))
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}

public func XCTAssert<T, I>(_ keys: [KeyPath<T, I>], of value: T, matches other: T, options: MatchOptions = .default, file: StaticString = #file, line: UInt = #line) where I: Matchable {
    do {
        for key in keys {
            try value[keyPath: key].matches(other[keyPath: key], context: MatchContext(options: options, file: file, line: line))
        }
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}

public func XCTAssertThrowing<T>(_ value: T, matches other: T, options: MatchOptions = .default, file: StaticString = #file, line: UInt = #line) throws where T: Matchable {
    try value.matches(other, context: MatchContext(options: options, file: file, line: line))
}

public func XCTAssertThrowing<T, I>(_ key: KeyPath<T, I>, of value: T, matches other: T, options: MatchOptions = .default, file: StaticString = #file, line: UInt = #line) throws where I: Matchable {
    try value[keyPath: key].matches(other[keyPath: key], context: MatchContext(options: options, file: file, line: line))
}

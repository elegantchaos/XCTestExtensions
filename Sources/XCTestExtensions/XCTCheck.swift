// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

public struct XCTCheckOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let ignoringWhitespace = Self(rawValue: 1 << 0)
    
    public static let `default`: XCTCheckOptions = []
}

public enum XCTCheckFailure: Error {
    public struct StringDetails {
        let description: String
        let value: String
        let expected: String
        let file: StaticString
        let line: UInt

        internal init(_ description: String, value: String, expected: String, file: StaticString, line: UInt) {
            self.description = description
            self.value = value
            self.expected = expected
            self.file = file
            self.line = line
        }
    }
    
    public struct IntDetails {
        let description: String
        let value: Int
        let expected: Int
        let file: StaticString
        let line: UInt
    }
    
    static func failure(_ message: String, value string: String, matches expected: String, ignoringWhitespace: Bool = false, file: StaticString = #file, line fileLine: UInt = #line) -> Self {
        return .strings(StringDetails(message, value: string, expected: expected, file: file, line: fileLine))
    }

    case strings(StringDetails)
    case integers(IntDetails)
}

public func XCTAssert<T>(_ value: T, matches other: T, options: XCTCheckOptions = .default, file: StaticString = #file, line: UInt = #line) where T: Matchable {
    do {
        try value.matches(other, context: MatchContext(options: options, file: file, line: line))
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}

public func XCTAssert<T, I>(_ key: KeyPath<T, I>, of value: T, matches other: T, options: XCTCheckOptions = .default, file: StaticString = #file, line: UInt = #line) where I: Matchable {
    do {
    try value[keyPath: key].matches(other[keyPath: key], context: MatchContext(options: options, file: file, line: line))
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}

public func XCTAssertThrowing<T>(_ value: T, matches other: T, options: XCTCheckOptions = .default, file: StaticString = #file, line: UInt = #line) throws where T: Matchable {
    try value.matches(other, context: MatchContext(options: options, file: file, line: line))
}

public func XCTAssertThrowing<T, I>(_ key: KeyPath<T, I>, of value: T, matches other: T, options: XCTCheckOptions = .default, file: StaticString = #file, line: UInt = #line) throws where I: Matchable {
    try value[keyPath: key].matches(other[keyPath: key], context: MatchContext(options: options, file: file, line: line))
}

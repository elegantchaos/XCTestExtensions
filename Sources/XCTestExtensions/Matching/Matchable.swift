// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public protocol Matchable {
    func matches(_ other: Self, context: MatchableContext) throws
}

public protocol MatchableContext {
    var file: StaticString { get }
    var line: UInt { get }
    var options: MatchOptions { get }
}

public protocol MatchFailedErrorBase: Error {
    var detail: String { get }
    var context: MatchableContext { get }
    var underlyingError: MatchFailedErrorBase? { get }
}

public struct MatchFailedError<T>: MatchFailedErrorBase {
    public init(_ detail: String, value: T, expected: T, underlyingError: MatchFailedErrorBase? = nil, context: MatchableContext) {
        self.detail = detail
        self.value = value
        self.expected = expected
        self.context = context
        self.underlyingError = underlyingError
    }
    
    public let detail: String
    public let value: T
    public let expected: T
    public let context: MatchableContext
    public let underlyingError: MatchFailedErrorBase?
}

public struct MatchContext: MatchableContext {
    public let options: MatchOptions
    public let file: StaticString
    public let line: UInt
}

public struct MatchOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let ignoringWhitespace = Self(rawValue: 1 << 0)
    
    public static let `default`: MatchOptions = []
}


extension MatchFailedError: CustomStringConvertible {
    public var description: String {
        let url = URL(fileURLWithPath: String(stringLiteral: context.file.description))
        let h = "Check failed at line \(context.line) of \(url.lastPathComponent)."
        let s = String(repeating: "-", count: h.count)
        return "\n\n\(s)\n\(h)\n\(s)\n\n\(detail)\n\nwas: \(value)\nexpected: \(expected)\npath: \(context.file)\n\n"
    }
}

extension Matchable {
    public func matches<F>(_ key: KeyPath<Self, F>, of other: Self, context: MatchableContext) throws where F: Matchable {
        let a = self[keyPath: key]
        let b = other[keyPath: key]
        try a.matches(b, context: context)
    }

    public func matches<F>(_ keys: [KeyPath<Self, F>], of other: Self, context: MatchableContext) throws where F: Matchable {
        for key in keys {
            let a = self[keyPath: key]
            let b = other[keyPath: key]
            try a.matches(b, context: context)
        }
    }
    
    public func matches(_ other: Self, options: MatchOptions = .default, file: StaticString = #file, line: UInt = #line) throws {
        try matches(other, context: MatchContext(options: options, file: file, line: line))
    }

    public func matches<F>(_ key: KeyPath<Self, F>, of other: Self, options: MatchOptions = .default, file: StaticString = #file, line: UInt = #line) throws where F: Matchable {
        try matches(key, of: other, context: MatchContext(options: options, file: file, line: line))
    }

    public func matches<F>(_ keys: [KeyPath<Self, F>], of other: Self, options: MatchOptions = .default, file: StaticString = #file, line: UInt = #line) throws where F: Matchable {
        try matches(keys, of: other, context: MatchContext(options: options, file: file, line: line))
    }

    public func wrappingChecks(_ message: String? = nil, of other: Self, context: MatchableContext, checks: () throws -> Void) throws {
        do {
            try checks()
        } catch {
            if let error = error as? MatchFailedErrorBase {
                let detail = message ?? "\(Self.self) instances failed to match"
                throw MatchFailedError(detail, value: self, expected: other, underlyingError: error, context: context)
            } else {
                throw error
            }
        }
    }
}

public extension RawRepresentable where RawValue: Matchable {
    func matches(_ other: Self, context: MatchableContext) throws {
        try rawValue.matches(other.rawValue, context: context)
    }
}

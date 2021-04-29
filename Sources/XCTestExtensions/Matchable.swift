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
    var options: XCTCheckOptions { get }
}

public struct MatchFailedError<T>: Swift.Error {
    internal init(_ detail: String, value: T, expected: T, context: MatchableContext) {
        self.detail = detail
        self.value = value
        self.expected = expected
        self.context = context
    }
    
    let detail: String
    let value: T
    let expected: T
    let context: MatchableContext
}

public struct MatchContext: MatchableContext {
    public let options: XCTCheckOptions
    public let file: StaticString
    public let line: UInt
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
}

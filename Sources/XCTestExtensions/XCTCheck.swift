// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct XCTCheckOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let ignoringWhitespace = Self(rawValue: 1 << 0)
    
    public static let `default`: XCTCheckOptions = []
}

public struct XCTCheckError<T>: Error {
    internal init(_ detail: String, value: T, expected: T, file: StaticString, line: UInt) {
        self.detail = detail
        self.value = value
        self.expected = expected
        self.file = file
        self.line = line
    }
    
    let detail: String
    let value: T
    let expected: T
    let file: StaticString
    let line: UInt
}

extension XCTCheckError: CustomStringConvertible {
    public var description: String {
        let url = URL(fileURLWithPath: String(stringLiteral: file.description))
        let h = "Check failed at line \(line) of \(url.lastPathComponent)."
        let s = String(repeating: "-", count: h.count)
        return "\n\n\(s)\n\(h)\n\(s)\n\n\(detail)\n\nwas: \(value)\nexpected: \(expected)\npath: \(file)\n\n"
    }
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

public protocol Checkable {
    func matches(_ other: Self, options: XCTCheckOptions, file: StaticString, line: UInt) throws
}

public func XCTCheck<T>(_ value: T, matches other: T, options: XCTCheckOptions = .default, file: StaticString = #file, line: UInt = #line) throws where T: Checkable {
    try value.matches(other, options: options, file: file, line: line)
}

public func XCTCheck<T, I>(_ key: KeyPath<T, I>, of value: T, matches other: T, options: XCTCheckOptions = .default, file: StaticString = #file, line: UInt = #line) throws where I: Checkable {
    try value[keyPath: key].matches(other[keyPath: key], options: options, file: file, line: line)
}

/// Check that two strings are equal.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
/// It optionally ignores whitespace at the beginning/end of each line.
extension String: Checkable {
    public func matches(_ expected: String, options: XCTCheckOptions, file: StaticString = #file, line: UInt = #line) throws {
        func failure(_ message: String) -> XCTCheckError<String> {
            return XCTCheckError(message, value: self, expected: expected, file: file, line: line)
        }
    
        let ignoringWhitespace = options.contains(.ignoringWhitespace)
        if self != expected {
            let lines = self.split(separator: "\n")
            let expectedLines = expected.split(separator: "\n")
            let lineCount = lines.count
            let expectedLineCount = expectedLines.count
            for n in 0 ..< min(lineCount, expectedLineCount) {
                var line = String(lines[n])
                var expectedLine = String(expectedLines[n])
                if ignoringWhitespace {
                    line = line.trimmingCharacters(in: .whitespaces)
                    expectedLine = expectedLine.trimmingCharacters(in: .whitespaces)
                }
                
                if line != expectedLine {
                    throw failure("strings different at line \(n).\n\nwas:\n\n\"\(line)\"\n\nexpected:\n\n\"\(expectedLine)\"\n")
                }
            }
            
            if lineCount < expectedLineCount {
                let missing = expectedLines[lineCount ..< expectedLineCount].joined(separator: "\n")
                throw failure("\(expectedLineCount - lineCount) lines missing from string.\n\n\(missing)")
            } else if lineCount > expectedLineCount {
                let extra = lines[expectedLineCount ..< lineCount].joined(separator: "\n")
                throw failure("\(lineCount - expectedLineCount) extra lines in string.\n\n\(extra)")
            }
        }
    }
}

extension Int: Checkable {
    public func matches(_ other: Int, options: XCTCheckOptions, file: StaticString, line: UInt) throws {
        if self != other {
            throw XCTCheckError("\(self) != \(other)", value: self, expected: other, file: file, line: line)
        }
    }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import Foundation

/// Assert that two strings are equal.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
/// It optionally ignores whitespace at the beginning/end of each line.
public func XCTAssertEqualLineByLine(_ string: String, _ expected: String, ignoringWhitespace: Bool = false, file: StaticString = #file, line fileLine: UInt = #line) {
    if string != expected {
        let lines = string.split(separator: "\n")
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
                XCTFail("Strings different at line \(n).\n\n\"\(line)\"\n\nvs.\n\n\"\(expectedLine)\"", file: file, line: fileLine)
                return
            }
        }
        
        if lineCount < expectedLineCount {
            let missing = expectedLines[lineCount ..< expectedLineCount].joined(separator: "\n")
            XCTFail("\(expectedLineCount - lineCount) lines missing from string.\n\n\(missing)", file: file, line: fileLine)
        } else if lineCount > expectedLineCount {
            let extra = lines[expectedLineCount ..< lineCount].joined(separator: "\n")
            XCTFail("\(lineCount - expectedLineCount) extra lines in string.\n\n\(extra)", file: file, line: fileLine)
        }
    }
}

/// Assert that two strings are equal, ignoring whitespace at the beginning/end of each line.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
public func XCTAssertEqual(_ string: String, _ expected: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqualLineByLine(string, expected, ignoringWhitespace: false, file: file, line: line)
}

/// Assert that two strings are equal, ignoring whitespace at the beginning/end of each line.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
public func XCTAssertEqualIgnoringWhitespace(_ string: String, _ expected: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqualLineByLine(string, expected, ignoringWhitespace: true, file: file, line: line)
}


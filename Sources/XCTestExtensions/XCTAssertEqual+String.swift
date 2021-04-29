// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import Foundation

/// Assert that two strings are equal.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
/// It optionally ignores whitespace at the beginning/end of each line.
public func XCTAssertEqualLineByLine(_ string: String, _ expected: String, ignoringWhitespace: Bool = false, file: StaticString = #file, line: UInt = #line) {
    let options: XCTCheckOptions = ignoringWhitespace ? [.ignoringWhitespace] : []
    XCTAssert(string, matches: expected, options: options, file: file, line: line)
}

/// Assert that two strings are equal, without ignoring whitespace at the beginning/end of each line.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
public func XCTAssertEqual(_ string: String, _ expected: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqualLineByLine(string, expected, ignoringWhitespace: false, file: file, line: line)
}

/// Assert that two strings are equal, ignoring whitespace at the beginning/end of each line.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
public func XCTAssertEqualIgnoringWhitespace(_ string: String, _ expected: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqualLineByLine(string, expected, ignoringWhitespace: true, file: file, line: line)
}


/// Assert that two arrays of strings are equal, without ignoring whitespace at the beginning/end of each line.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
public func XCTAssertEqual(_ strings: [String], _ expected: [String], file: StaticString = #file, line: UInt = #line) {
    for (string, expected) in zip(strings, expected) {
        XCTAssertEqualLineByLine(string, expected, ignoringWhitespace: false, file: file, line: line)
    }
}

/// Assert that two strings are equal, ignoring whitespace at the beginning/end of each line.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
public func XCTAssertEqualIgnoringWhitespace(_ strings: [String], _ expected: [String], file: StaticString = #file, line: UInt = #line) {
    for (string, expected) in zip(strings, expected) {
        XCTAssertEqualLineByLine(string, expected, ignoringWhitespace: true, file: file, line: line)
    }
}

